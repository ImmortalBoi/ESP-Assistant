FROM python:latest

RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://raw.githubusercontent.com/arduino/arduino-cli/master/install.sh | BINDIR=/usr/bin sh
RUN arduino-cli core update-index

# COPY compile.py /usr/src/app/
WORKDIR /usr/src/sketch
COPY . .
RUN pip install -r requirements.txt
EXPOSE 5000
CMD ["flask", "run", "--host", "0.0.0.0"]
# CMD [ "python", "-u", "/usr/src/app/compile.py" ]
