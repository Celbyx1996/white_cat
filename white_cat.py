#!/usr/bin/env python3
"""WHITE_CAT - Advanced Adversary Intelligence Platform"""

import sys
import asyncio
import argparse
import logging
from pathlib import Path
from datetime import datetime

from src.core.config import Config
from src.core.logger import setup_logging
from src.core.database import Database
from src.tier1.auditd_monitor import AuditdMonitor
from src.tier2.network_monitor import NetworkMonitor
from src.tier3.ai_analyzer import AIAnalyzer
from src.reporting.report_generator import ReportGenerator


class WhiteCat:
    def __init__(self, config_path="config/default.yaml"):
        self.config = Config(config_path)
        self.logger = setup_logging(self.config.get("logging"))
        self.db = Database(self.config.get("database"))
        self.tier1 = AuditdMonitor(self.config, self.db)
        self.tier2 = NetworkMonitor(self.config, self.db)
        self.tier3 = AIAnalyzer(self.config, self.db)
        self.report_gen = ReportGenerator(self.config, self.db)
        self.running = False

    async def start(self):
        self.logger.info("🐈‍⬛ WHITE_CAT Starting...")
        self.running = True
        try:
            tasks = [
                asyncio.create_task(self.tier1.start()),
                asyncio.create_task(self.tier2.start()),
                asyncio.create_task(self.tier3.start())
            ]
            await asyncio.gather(*tasks)
        except KeyboardInterrupt:
            await self.stop()

    async def stop(self):
        self.logger.info("🐈‍⬛ WHITE_CAT Stopping...")
        self.running = False
        await self.tier1.stop()
        await self.tier2.stop()
        await self.tier3.stop()
        self.db.close()

    def generate_report(self, output_path=None):
        report = self.report_gen.create_full_report()
        if output_path:
            with open(output_path, 'w') as f:
                f.write(report)
        else:
            print(report)


def main():
    parser = argparse.ArgumentParser(description="WHITE_CAT Intelligence Platform")
    parser.add_argument("-c", "--config", default="config/default.yaml")
    parser.add_argument("-r", "--report", action="store_true")
    parser.add_argument("-o", "--output")
    args = parser.parse_args()
    
    cat = WhiteCat(args.config)
    if args.report:
        cat.generate_report(args.output)
    else:
        asyncio.run(cat.start())


if __name__ == "__main__":
    main()
