DBMS SEMESTER PROJECT
=====================

## Installation
### Linux
Install the following packets :
- mysql-server
- nodejs
- npm

full command for ubuntu : `sudo apt-get install mysql-server nodejs npm`

install sails globally : `sudo npm install -g sails`

install coffee-script globally : `npm install -g coffee-script`

install bower globally : `sudo npm install -g bower`

Then clone the repo.

When you are in the repo run the following command `npm install` it will resoleve all the dependencies of the project (server side).

Then run `sudo bower install`, it will install all the client-side dependencies.

rename `config/local.demo.js` and add your password, username and database on your computer. When you are done rename local.demo.js to local.js

## Running the webserver

You just have to run the following command in the root directory of the project :
```
sails lift
```

### parameters

- `--port [port]` : change the port of the server (in some OS's root access might be required to use ports below 1024)
- `--prod` : start the server in production mode (port 80, safe configuration, and low logging)
- `-r, --reset-strucutre` : run the SQL setup script in order to reset the database schema before starting the server
- `-p, --parse` : parse the CSV files and import them into the database before starting the server

