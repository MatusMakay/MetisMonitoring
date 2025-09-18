FROM python:3.11-slim

WORKDIR /app

# Copy the entire directory into the container
COPY . .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

RUN chmod +x main.py

CMD ["python3", "main.py"]
