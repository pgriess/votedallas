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

Run the website locally (will automatically refresh)

```console
$ make build
```

Deploy the website

```console
$ make deploy
```

## Beta site

Publish to [beta.votedallas.org](https://beta.votedallas.org/) as follows:

```bash
make publish AWS_S3_BUCKET=beta.votedallas.org AWS_CF_DISTRIBUTION=E1872JDMLLUW5Q
```
