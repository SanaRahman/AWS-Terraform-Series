FROM python:3

WORKDIR /app

COPY requirments.txt .
RUN pip install --no-cache-dir -r requirments.txt
COPY server.py .
COPY .env .

EXPOSE 5001

CMD ["python3", "server.py"]
