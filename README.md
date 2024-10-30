# Setup

Create Python virtual environment

```console
python -m venv venv
```

Activate Python virtual environment
```
. ./venv/bin/activate
```

Install requirements

```console
pip install -r requirements.txt
```

Build the website

```console
mkdocs build
```

Push the website

```console
aws s3 sync site/ s3://www.votedallas.org/
```
