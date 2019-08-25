/// Logging utilities
\d .log
print:{(-1)(" " sv string (.z.D;.z.T)),x;};
out:{[x]print[": INFO : ",x]};
err:{[x]print[": ERROR : ",x]};
errexit:{err x;err"Exiting";exit 1};
sucexit:{out "Success. Exiting";exit 0};
\d .

/// Parameter handling
d:first each .Q.opt .z.x;
if[not `database in key d; .log.out "Usage: hdbmaint.q -database \"hdbdir\""; .log.errexit "Missing parameter"];
database:hsym `$first system raze "readlink -f ",d[`database];
if[not `addcol in key d; .log.out "Attempting to load dbmaint.q in current directory"; @[value;"system \"l ./dbmaint.q\""; {.log.errexit "Cound not load dbmaint.q"}]];

/// Function definitions
backup_hdb:{[x]
    backup_path:(first system "dirname ",string[x]),"/";
    backup_dir:"hdbdir_bak/",{ssr[x;y;"-"]}/["-" sv string each (.z.D;.z.T);(".";":")];
    
    .log.out "Backing up HDB tables proir to maintenance";
    .log.out "HDB Directory: ",string x;
    .log.out "Backup Directory: ",backup_path;

    .log.out "Creating ",backup_dir;
    system "mkdir -p ",1_ backup_path,backup_dir;

    .log.out "Copying database..."
    system "rsync -aL ",(1_ string[x]),"/ ",(1_ backup_path,backup_dir);

    .log.out "Backup complete";
 }

load_hdb:{
    .log.out "Loading database: ",string x;
    system "l ",1_string x;
 }

checks:{[x]
    load_hdb database;

    validate:{$[x;"true";"false"]};

    .log.out "Running ",x,"-checks...";

    .log.out "Checking if trades.val exists: ",validate[`val in cols trades];
    .log.out "Checking if all syms are uppercase: ",validate[all (raze string sym) in .Q.A,.Q.n];

    .log.out x,"-checks complete";
 }


/// Main body
main:{
    backup_hdb database;

    checks "pre";
    
    .log.out "Adding val to trades table...";
    addcol[database;`trades;`val;0Nf];

    .log.out "Setting val as (qty*px) in trade table ...";
    calcVal:{(hsym `$(y,"/",string[x],"/trades/val")) set {x[0]*x[1]} get@'(hsym`$/:(y,"/",string[x],"/trades/qty";y,"/",string[x],"/trades/px"))}[;1_string database];
    calcVal each date;

    .log.out "Changing symbols to uppercase...";
    (` sv (database;`sym)) set  @[sym;(where sym=distinct raze {[x;y] exec sym from select sym from x where date=y}[`trades;] each date);upper];

    .log.out "Maintenance complete";

    checks "Post";

    .log.sucexit[];
 }

/// Entry point
@[main;`;{.log.err "Error running main: ",x;exit 1}];
