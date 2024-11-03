#! /bin/sh

# A list of possible qdbus names
# Fedora uses qdbus-qt6
# OpenSUSE uses qdbus6
qdbus_names="\
qdbus-qt6 \
qdbus6 \
qdbus"

for name in ${qdbus_names}; do
    $name > /dev/null
    if test $? -eq 0; then
        qdbus_name=$name
    fi
done

echo $qdbus_name
