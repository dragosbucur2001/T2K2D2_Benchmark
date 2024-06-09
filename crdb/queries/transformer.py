#!/usr/bin/env python3

from argparse import ArgumentParser, RawTextHelpFormatter
import re
import os

# \set var_name var_value
declaration = re.compile(r"\\set (\w+) (.+)")


def transform_query(path, inplace):
    lines = []
    with open(path, "r") as file:
        lines = file.readlines()

    variables = {}
    updated_content = []

    for line in lines:
        if line.find("\\q") != -1:
            continue

        match = declaration.match(line)
        if match:
            variable_name = match.group(1)
            variable_value = match.group(2)
            variable_value = variable_value.replace("'''", "'")
            variables[variable_name] = variable_value.strip()

            updated_content.append(f"-- {line}")
        else:
            updated_content.append(line)

    file_content = "".join(updated_content)

    for variable in variables:
        file_content = re.sub(rf":{variable}\b", variables[variable], file_content)

    file_content = re.sub(r"::float\b", "", file_content)

    if inplace:
        with open(path, "w") as file:
            file.write(file_content)
    else:
        with open(f"{path}.adapted", "w") as file:
            file.write(file_content)


if __name__ == "__main__":
    parser = ArgumentParser(description=__doc__, formatter_class=RawTextHelpFormatter)
    parser.add_argument("-i", help="Update files in place", action="store_true")

    opt = parser.parse_args()

    for root, dirs, files in os.walk("."):
        for file_name in files:
            if not file_name.endswith(".sql"):
                continue

            path = os.path.join(root, file_name)
            print(path)
            transform_query(path, opt.i)
