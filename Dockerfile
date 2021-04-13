# To use this container, build it, and then mount the current directory.

# BUILD
# docker build -t imls/mkdocs .

# RUN

# To create a new set of docs
# docker run -v ${PWD}:/src imls/mkdocs new wifisess

# To serve the HTML
# In the project directory (eg. `cd wifisess`)
# docker run -v ${PWD}:/src -p 8000:8000 imls/mkdocs serve -a 0.0.0.0:8000

FROM python:3.8
RUN pip install --upgrade pip && pip install mkdocs

WORKDIR /src
ENTRYPOINT ["mkdocs"]