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


















# # Base image for development
# FROM python:3.13-alpine AS Base

# # Set working directory
# WORKDIR /app

# # Install deps
# COPY requirements.txt .
# RUN pip install --no-cache-dir -r requirements.txt

# # Copy source into /app/src (preserve directory structure)
# COPY . .

# # Production image
# From python:3.13-alpine AS Production

# # Set working directory
# WORKDIR /app

# # Create a non-root user and set permissions
# RUN adduser -D appuser
# USER appuser

# # Copy the base image
# COPY --from=Base /app/src .
# COPY --from=Base /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages


# # Expose the port
# EXPOSE 8000

# # Start the application
# CMD ["python", "-m", "uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]

