# RPA-DB-Conversion
A collection of scripts that I use to convert my old style JSON files used for my powershell scripts to a standard JSON format.

### Uses
1. I use some of these scripts to convert large arrays of objects formatted as
   ```
   [
     {
       "order_id": {
         key: value,
       },
       etc...
     }
   ]
   ```
2. Some of the JSON files I use have bad data that needs to be handled (dates, null values etc)

### Usage
Point to the desired JSON file to convert and submit to the PostgreSQL DB. The DB will handle duplicates.
There is currently no method of adding jobs to the jobs table, so the job_id field is static, not a relation.
