FROM python:3.7-slim-buster

ENV LC_ALL=C.UTF-8

ENV LANG=C.UTF-8

WORKDIR /home/streamlit_user/play_streamlit

COPY requirements.txt ./

RUN pip install -U pip pip-tools && \
    pip-sync requirements.txt

RUN useradd -ms /bin/bash streamlit_user

USER streamlit_user

COPY config.toml /home/streamlit_user/.streamlit/

COPY credentials.toml /home/streamlit_user/.streamlit/

COPY . .

EXPOSE 8501

CMD streamlit run app.py
