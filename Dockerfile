# =====================================================
# 1️⃣ BASE — common setup
# =====================================================
FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

# System deps (chung)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN pip install --no-cache-dir poetry \
    && poetry config virtualenvs.create false

# Copy dependency files first (for caching)
COPY pyproject.toml poetry.lock* ./


# =====================================================
# 2️⃣ DEV — dùng cho local & CI
# =====================================================
FROM base AS dev

# Install all deps (include dev)
RUN poetry install --no-interaction --no-root --with dev

# Copy source
COPY src ./src
COPY tests ./tests

EXPOSE 8000

CMD ["uvicorn", "src.apps.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]


# =====================================================
# 3️⃣ PROD — nhẹ, chỉ runtime
# =====================================================
FROM base AS prod

# Install only production deps
RUN poetry install --no-interaction --only main

# Copy source code
COPY src ./src

EXPOSE 8000

# Recommended production run
CMD ["uvicorn", "src.apps.main:app", "--host", "0.0.0.0", "--port", "8000"]
