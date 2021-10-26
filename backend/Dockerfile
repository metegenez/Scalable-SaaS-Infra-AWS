FROM public.ecr.aws/bitnami/python:3.7.12
ENV PYTHONUNBUFFERED=1


# set a directory for the app
WORKDIR /usr/backend

# copy all the files to the container
COPY . .
# install dependencies
RUN pip install -r requirements.txt
RUN pip install psycopg2-binary

# tell the port number the container should expose
EXPOSE 8000
