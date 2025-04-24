#!/usr/bin/env python3
import click
from trogon import tui
import boto3


@tui()
@click.group()
def cli():
    print("Hello from main!")

@cli.command()
def sub():
    print("Hello from sub!")


if __name__ == "__main__":
    cli()
