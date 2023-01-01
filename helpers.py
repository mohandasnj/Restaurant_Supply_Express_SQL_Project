import re

def parseSQL(file):
    # Open the .sql file
    sql_file = open(file, 'r')

    # Create an empty command string
    sql_commands = []

    # Iterate over all lines in the sql file
    cmd = ''
    proc = False
    com = False
    for line in sql_file:
        #print(cmd + '\n')
        line = line.strip()
        if line.startswith('create procedure') or line.startswith('create function'):
            proc = True
        if line.startswith('end') and line.strip('\n').endswith('//'):
            proc = False
            sql_commands.append(cmd + ' end')
            cmd = ''
            continue

        if line.startswith('/*'):
            com = True
        if line.strip('\n').endswith('*/'):
            com = False
            continue
        if line.startswith('--') or line.startswith('delimiter') or com:
            continue
        else:
            cmd += line

        cmd = cmd.replace('\n', ' ')
        cmd = " ".join(cmd.split())

        if not proc and cmd.strip('\n').endswith(';'):
            sql_commands.append(cmd)
            cmd = ''
        else:
            cmd += ' '

    #print(sql_commands[18])
    return sql_commands

#q = parseQuery('sql/procedures.sql')
#for s in q:
   #print(s + '\n')
#print(parseQuery('sql/procedures.sql'))