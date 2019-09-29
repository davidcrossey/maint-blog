#!/bin/bash
q setuphdb.q -db hdb
bash hdbmaint.sh -db ./hdb -action renamecol -table trades -oldname px -newname price 2>&1 >hdbmaint.log
bash hdbmaint.sh -db ./hdb -action addcol -table trades -colname industry -fn 'enlist "tech"' 2>&1 >>hdbmaint.log
bash hdbmaint.sh -db ./hdb -action fncol -table trades -colname industry -fn '{(` sv x,`sym)?`$y} db' 2>&1 >>hdbmaint.log