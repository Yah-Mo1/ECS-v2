FROM python:3.13-alpine

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH=/home/nonroot/.local/bin:$PATH

# Set working directory
WORKDIR /app

# Install deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source into /app/src (preserve directory structure)
COPY . .

# Create non-root user with no login shell and no home directory
RUN adduser --system --no-create-home --disabled-password --shell /sbin/nologin nonroot


# Set user to non-root user
USER nonroot


EXPOSE 8000


HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/healthz')" || exit 1


CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]


