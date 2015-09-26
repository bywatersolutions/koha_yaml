# NAME

koha\_yaml.pl -- import and export Koha data using YAML files.

# SYNOPSIS

    koha_yaml.pl --dump_file DUMP.yaml

    koha_yaml.pl --load_file LOAD.yaml

The default dump file will be **Koha.yaml**. The default load file will
be **Koha\_load.yaml**

As written, the script has very little control over what it imported
and exported -- any data in the load file will be imported in to Koha,
and all data in the Koha database will be exported to the dump file,
even if _--dump\_file_ is not specified.
