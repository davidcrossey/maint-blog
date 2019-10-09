/// Logging utilities
\d .log
print:{(-1)(" " sv string (.z.D;.z.T)),x;};
out:{[x]print[": INFO : ",x]};
err:{[x]print[": ERROR : ",x]};
errexit:{err x;err"Exiting";exit 1};
sucexit:{out "Maintenance complete"; out "Success. Exiting";exit 0};
usage:{[x] errexit "Missing param(s) Usage: hdbmaint.q "," " sv "-",'string distinct `db`action,x };
\d .

/// dbmaint.q check
if[not `addcol in key `.; .log.out "Attempting to load dbmaint.q in current directory"; @[system;"l ./dbmaint.q"; {.log.errexit "Could not load dbmaint.q"}]];

/// Parameter handling
d:.Q.opt .z.x;
fn:$[`fn in key d;" " sv d[`fn];""];
d:first each d; d[`fn]:fn;
if[not all `db`action in key d; .log.usage `db`action ];
db:hsym `$first system raze "readlink -f ",d[`db];
action:`$d[`action];

/// Function definitions
load_db:{
    .log.out "Loading database: ",string x;
    system "l ",1_string x;
 }

param_check:{
    requiredInputs:`addcol`deletecol`renamecol`fncol!(`table`colname`fn;`table`colname;`table`oldname`newname;`table`colname`fn);
    
    params:requiredInputs[y];
    if[not all params in key[x]; .log.usage[params]];

    .log.out "Params: ",.Q.s1 x;
 }

backup:{
    backup_path:(first system "dirname ",string[x]),"/";
    backup_dir:"hdb_bak/",{ssr[x;y;"-"]}/["-" sv string each (.z.D;.z.T);(".";":")];

    .log.out "Creating ",backup_dir;
    system "mkdir -p ",1_ backup_path,backup_dir;

    .log.out "Copying sym file...";
    system "rsync -aL ",(1_ string[x]),"/sym ",(1_ backup_path,backup_dir);

    .log.out "Backup complete";
 }

/// Main body
main:{
    load_db db;

    param_check[d;action];

    backup db;

    $[
        action~`addcol;
            addcol[db;`$d[`table];`$d[`colname];value d[`fn]];
        action~`deletecol;
            deletecol[db;`$d[`table];`$d[`colname]];
        action~`renamecol;
            renamecol[db;`$d[`table];`$d[`oldname];`$d[`newname]];
        action~`fncol;
            fncol[db;`$d[`table];`$d[`colname];value d[`fn]]
    ];

    .log.sucexit[];
 }

/// Entry point
@[main;`;{.log.err "Error running main: ",x;exit 1}];
