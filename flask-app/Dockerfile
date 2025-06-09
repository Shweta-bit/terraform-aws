# Use official Python image
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy source files
COPY main.py requirements.txt ./

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port
EXPOSE 8081

# Run the application
CMD ["python", "main.py"]
