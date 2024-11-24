import argparse
import json
import subprocess
import textwrap


PSQL_LEADER = "postgresql/leader"
PSQL_CMD_TEMPLATE = (
    "psql {psql_uri}/landscape-standalone-main -c "
    "'SELECT row_to_json(api_credentials) FROM api_credentials LIMIT 1'"
)


def run_psql_cmd(unit: str, psql_uri: str, model: str | None = None):
    cmd = ["juju", "exec"]
    if model:
        cmd.extend(["--model", model])
    cmd.extend(["--unit", unit, PSQL_CMD_TEMPLATE.format(psql_uri=psql_uri)])

    try:
        return subprocess.run(
            cmd,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except subprocess.CalledProcessError as e:
        print(e.stderr)
        raise


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("-u", "--unit", type=str, default=PSQL_LEADER)
    parser.add_argument("-m", "--model", type=str, required=False)
    parser.add_argument("psql_uri", type=str)
    return parser.parse_args()


def decode(data):
    return bytearray.fromhex(data.split("x")[1]).decode()


def main():
    args = parse_args()
    proc = run_psql_cmd(args.unit, args.psql_uri, args.model)
    lines = [x.decode() for x in proc.stdout.splitlines()]
    json_lines = [x for x in lines if "access_key" in x]
    if len(json_lines) > 1:
        raise RuntimeError(f"Too many JSON records returned: {len(json_lines)}")
    api_keys = json.loads(json_lines[0])
    result = {
        "access_key_id": decode(api_keys["access_key_id"]),
        "access_secret_key": decode(api_keys["access_secret_key"]),
    }
    print(json.dumps(result))


if __name__ == "__main__":
    main()
