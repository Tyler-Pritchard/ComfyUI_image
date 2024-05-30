# Use an official Python runtime as a parent image
FROM python:3.12

# Set the working directory in the container
WORKDIR /usr/src/app

# Install necessary packages
RUN apt-get update && \
    apt-get install -y git wget patch && \
    pip install --upgrade pip

# Install PyTorch with CPU support
RUN pip install --no-cache-dir torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install HuggingFace's Diffusers library
RUN pip install --no-cache-dir diffusers transformers

# Install Jupyter Notebook
RUN pip install --no-cache-dir jupyter

# Clone ComfyUI repository
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# Copy the patch file into the Docker image
COPY patch_model_management.patch /usr/src/app/ComfyUI/

# Install ComfyUI requirements
WORKDIR /usr/src/app/ComfyUI
RUN pip install --no-cache-dir -r requirements.txt

# Apply the patch to ComfyUI
RUN patch -p0 < patch_model_management.patch

# Download Stable Diffusion v1.4 model files separately
RUN mkdir -p /usr/src/app/models/stable-diffusion-v1-4
WORKDIR /usr/src/app/models/stable-diffusion-v1-4

RUN wget https://huggingface.co/CompVis/stable-diffusion-v-1-4-original/resolve/main/sd-v1-4.ckpt || echo "sd-v1-4.ckpt not found"
RUN wget https://huggingface.co/CompVis/stable-diffusion-v-1-4-original/resolve/main/config.json || echo "config.json not found"
RUN wget https://huggingface.co/CompVis/stable-diffusion-v-1-4-original/resolve/main/model_index.json || echo "model_index.json not found"

# Expose port for Jupyter
EXPOSE 8888

# Expose port for ComfyUI
EXPOSE 5000

# Start Jupyter Notebook and ComfyUI
CMD ["sh", "-c", "jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root & cd /usr/src/app/ComfyUI && python main.py"]
