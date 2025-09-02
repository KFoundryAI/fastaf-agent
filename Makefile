.PHONY: help test lint format clean

help:
	@echo "Available commands:"
	@echo "  make test    - Run all tests"
	@echo "  make lint    - Run linters"
	@echo "  make format  - Format code"
	@echo "  make clean   - Clean build artifacts"

test:
	@echo "Running tests..."
	# Add test commands here

lint:
	@echo "Running linters..."
	# Add lint commands here

format:
	@echo "Formatting code..."
	# Add format commands here

clean:
	@echo "Cleaning..."
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete
