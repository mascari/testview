import sys


def get_version(file_name):
    with open("version.txt") as file:
        version = file.readline()
        print("Old version: " + version)
        file.close()
    return version

def increase_major(file_name, version):
    v = version.split('.')
    v[0] = str(int(v[0]) + 1)
    v[1] = "0"
    v[2] = "0"
    new_version = str(v[0]) + '.' + str(v[1]) + '.' + str(v[2])
    print("New version: " + new_version)


    with open(file_name, "w") as file:
        file.write(new_version)
        file.close()

def increase_minor(file_name, version):
    v = version.split('.')
    v[1] = str(int(v[1]) + 1)
    v[2] = "0"
    new_version = str(v[0]) + '.' + str(v[1]) + '.' + str(v[2])
    print("New version: " + new_version)
    with open(file_name, "w") as file:
        file.write(new_version)
        file.close()

def increase_path(file_name, version):
    v = version.split('.')
    v[2] = str(int(v[2]) + 1)
    new_version = str(v[0]) + '.' + str(v[1]) + '.' + str(v[2])
    print("New version: " + new_version)
    with open(file_name, "w") as file:
        file.write(new_version)
        file.close()

version = get_version("version.txt")
if len(sys.argv)<2:
    print("choose a argument: major, minor or path")
    v = input()
    if v == 'major':
        increase_major("version.txt", version)
    elif v == 'minor':
        increase_minor("version.txt", version)
    elif v == 'path':
        increase_path("version.txt", version)
    input()
else:
    if sys.argv[1] == 'major':
        increase_major("version.txt", version)
    elif sys.argv[1] == 'minor':
        increase_minor("version.txt", version)
    elif sys.argv[1] == 'path':
        increase_path("version.txt", version)
    else:
        print("choose a argument: major, minor or path")

