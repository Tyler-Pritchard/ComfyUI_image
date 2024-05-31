# Use the official Python base image
FROM python:3.12-slim

# Set the working directory
WORKDIR /usr/src/app

# Install necessary packages and dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libssl-dev \
    libffi-dev \
    libxml2-dev \
    libxslt1-dev \
    zlib1g-dev \
    libjpeg-dev \
    libpng-dev \
    patch \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the application files to the container
COPY . .

# Ensure comfy directory exists
RUN mkdir -p comfy

# Copy model_management.py to the comfy directory
COPY comfy/model_management.py comfy/model_management.py

# Copy the patch file to the container
COPY patches/patch_model_management.patch /usr/src/app/patch_model_management.patch

# List the contents of the /usr/src/app directory for debugging
RUN ls -l /usr/src/app

# List the contents of the /usr/src/app/comfy directory for debugging
RUN ls -l /usr/src/app/comfy

# Apply the patch file
RUN patch -p1 < /usr/src/app/patch_model_management.patch

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the necessary ports
EXPOSE 5000

# Run the application
CMD ["python", "app.py"]
