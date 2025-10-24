FROM python:3.13-alpine

ENV PYTHONUNBUFFERED=1

WORKDIR /app

# Install deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source into /app/src (preserve directory structure)
COPY . .

EXPOSE 8000

# Start FastAPI via uvicorn without needing __init__.py
#CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000", "--app-dir", "/app/src"]

CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]