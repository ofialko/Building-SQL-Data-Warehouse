# Building SQL Data Warehouse

At AMES I learned lots of things about Microsoft SQL server. 
Modules include "Querying Microsoft SQL Server", "Administering a Microsoft SQL Server Database" and " Implementing data warehouses with Microsoft SQL Server". In my final project I built a data base (see the diagram above) for an online retail store selling CD's, DVD's and Games.

TOOLS

 * I used DDL, DML and SQL Server Managment Studio to create the database "DigitalIX".

 * To populate tables with data from .csv files, I developed a SSIS package.

 * There are other SSIS packages used to perform incremental update of the database when new data arrive.

 * I created various stored procedures used for encyption and decryption of passwords and credit cards numbers of customers, adding customers, placing orders etc...

 * I created several views to see order history, orders and products information.

 * I developed backup strategy.

 * Finally, I developed high availability solution in case of the database failure.

Full description of the project is provided in [this file](SQL Server Final Project.pdf).
My solution is described in [this file](Description of a final project.pdf)


![Data Base][db]

[db]: https://github.com/ofialko/Building-SQL-Data-Warehouse/blob/master/DataBase.png
