FROM python:3.10-slim

# Create user and give permissions (Required for Hugging Face Spaces)
RUN useradd -m -u 1000 user
USER user
ENV PATH="/home/user/.local/bin:$PATH"

# Set the working directory
WORKDIR /app

# Upgrade pip and install dependencies
COPY --chown=user "Source Code/RecipeLens/requirements.txt" requirements.txt
RUN pip install --no-cache-dir --upgrade -r requirements.txt

# Copy all the project files into the container
COPY --chown=user . /app

# Change directory to where manage.py is located
WORKDIR "/app/Source Code/RecipeLens/src"

# Collect static files for production (Whitenoise)
RUN python manage.py collectstatic --noinput

# Start the Gunicorn server on port 7860 (Required by HF Spaces)
CMD ["gunicorn", "RecipeLens.wsgi:application", "--bind", "0.0.0.0:7860", "--workers", "2", "--threads", "4", "--timeout", "120"]
