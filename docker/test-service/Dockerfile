FROM python:3-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1

# Create a non-root user
RUN adduser --disabled-password --gecos '' appuser

WORKDIR /app

# Install curl with minimal dependencies, then clean up
RUN apt-get update && \
    apt-get install --no-install-recommends -y curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy only requirements first to leverage Docker cache
COPY src/requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the source code
COPY src/ ./src/
WORKDIR /app/src

# Switch to non-root user
USER appuser

EXPOSE 8080

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]