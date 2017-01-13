/* This file is a part of the omobus-agent-db project.
 * Copyright (c) 2006 - 2017 ak-obs, Ltd. <info@omobus.net>.
 * All rights reserved.
 *
 * This program is a free software. Redistribution and use in source
 * and binary forms, with or without modification, are permitted provided
 * that the following conditions are met:
 * 
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 
 * 2. The origin of this software must not be misrepresented; you must
 *    not claim that you wrote the original software.
 * 
 * 3. Altered source versions must be plainly marked as such, and must
 *    not be misrepresented as being the original software.
 * 
 * 4. The name of the author may not be used to endorse or promote
 *    products derived from this software without specific prior written
 *    permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
 * GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/* ** omobus-agent-db database schema.
 * **
 * ** ATTENTION: This database schema is used only for direct connection 
 * ** distributors to the omobus cloud server.
 * **
 */

set QUOTED_IDENTIFIER on
go
create login omobus with password = '0'
go
create user omobus for login omobus
go
create database "omobus-agent-db"
go
use "omobus-agent-db"
go
sp_changedbowner 'omobus'
go
alter database "omobus-agent-db" set ANSI_NULL_DEFAULT on
alter database "omobus-agent-db" set ANSI_NULLS on
alter database "omobus-agent-db" set ANSI_PADDING on
alter database "omobus-agent-db" set QUOTED_IDENTIFIER on 
alter database "omobus-agent-db" set concat_null_yields_null on
go
-- **** mssql 2005 and higher ****
alter database "omobus-agent-db" set ALLOW_SNAPSHOT_ISOLATION on
go


-- **** domains ****

execute sp_addtype address_t, 'varchar(256)'
execute sp_addtype art_t, 'varchar(24)'
execute sp_addtype bool_t, 'smallint'
execute sp_addtype code_t, 'varchar(32)'
execute sp_addtype currency_t, 'numeric(18,4)'
execute sp_addtype date_t, 'varchar(10)'
execute sp_addtype datetime_t, 'varchar(19)'
execute sp_addtype descr_t, 'varchar(256)'
execute sp_addtype doctype_t, 'varchar(16)'
execute sp_addtype discount_t, 'numeric(5,2)'
execute sp_addtype ftype_t, 'smallint', 'not null'
execute sp_addtype int32_t, 'int'
execute sp_addtype int64_t, 'numeric(10)'
execute sp_addtype note_t, 'varchar(1024)'
execute sp_addtype numeric_t, 'numeric(16,4)'
execute sp_addtype time_t, 'varchar(5)'
execute sp_addtype ts_t, 'datetime'
execute sp_addtype uid_t, 'varchar(48)'
execute sp_addtype uids_t, 'varchar(2048)'
execute sp_addtype volume_t, 'numeric(10,6)'
execute sp_addtype weight_t, 'numeric(12,6)'

go


-- **** ERP -> OMOBUS streams ****

create table accounts (
    account_id 		uid_t 		not null primary key,
    pid 		uid_t 		null,
    code 		code_t 		null,
    ftype 		ftype_t 	not null default 0,
    descr 		descr_t 	not null,
    address 		address_t 	not null,
    rc_id 		uid_t		null, 		/* -> retail_chains */
    chan_id 		uid_t 		null,
    poten_id 		uid_t 		null,
    locked 		bool_t 		null
);

create table account_params (
    account_id 		uid_t 		not null primary key,
    group_price_id 	uid_t 		null,
    locked 		bool_t 		null default 0,
    payment_delay 	int32_t 	null,
    payment_method_id 	uid_t 		null
);

create table account_prices (
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    pack_id 		uid_t 		not null,
    price 		currency_t 	not null,
    primary key (account_id, prod_id)
);

create table blacklist (
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    locked 		bool_t 		null,
    primary key (account_id, prod_id)
);

create table brands (
    brand_id 		uid_t 		not null primary key,
    descr 		descr_t 	not null
);

create table categories (
    categ_id 		uid_t 		not null primary key,
    descr 		descr_t 	not null
);

create table channels (
    chan_id 		uid_t 		not null primary key,
    descr 		descr_t 	not null
);

create table constants (
    const_id 		uid_t 		not null primary key, -- mutuals:date, debts:date, wareh_stocks:date
    value 		varchar(64) 	not null
);

insert into constants values('mutuals:date', '');
insert into constants values('debts:date', '');
insert into constants values('wareh_stocks:date', '');

create table debts (
    account_id 		uid_t 		not null primary key,
    debt 		currency_t 	not null
);

create table discounts (
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    discount 		discount_t 	not null default 0,
    min_discount 	discount_t 	not null,
    max_discount 	discount_t 	not null,
    primary key (account_id, prod_id)
);

create table erp_docs (
    doc_id 		uid_t 		not null,
    erp_id 		uid_t 		not null,
    pid 		uid_t 		null, /* parent erp_id */
    erp_no 		uid_t 		not null,
    erp_dt 		datetime_t 	not null,
    amount 		currency_t 	not null,
    status 		int32_t 	not null default 0 check (status between -1 and 1), -- -1 - delete, 0 - normal, 1 - closed
    doc_type 		doctype_t 	not null, -- order, reclamation, contract, shipment, return, movement
    delivery_date 	date_t 		null,
    waybill_no 		uid_t 		null,
    ivoice_no 		uid_t 		null,
    discount 		currency_t 	not null,
    vat 		currency_t 	not null,
    vat_rate 		int32_t 	not null,
    primary key (doc_id, erp_id)
);

create table erp_products (
    doc_id 		uid_t 		not null,
    erp_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    pack_id 		uid_t 		not null,
    qty 		numeric_t 	not null,
    discount 		discount_t 	not null,
    amount 		currency_t 	not null,
    price 		currency_t 	not null,
    vat 		currency_t 	not null,
    primary key (doc_id, erp_id, prod_id)
);

create table group_prices (
    group_price_id 	uid_t 		not null,
    prod_id 		uid_t 		not null,
    pack_id 		uid_t 		not null,
    price 		currency_t 	not null,
    primary key (group_price_id, prod_id)
);

create table manufacturers (
    manuf_id 		uid_t 		not null primary key,
    descr 		descr_t 	null
);

create table my_accounts (
    user_id 		uid_t 		not null,
    account_id 		uid_t 		not null,
    primary key (user_id, account_id)
);

create table mutuals (
    account_id 		uid_t 		not null primary key,
    mutual 		currency_t 	not null
);

create table mutuals_history (
    account_id 		uid_t 		not null,
    erp_id 		uid_t 		not null,
    erp_no 		uid_t 		not null,
    erp_dt 		datetime_t 	not null,
    amount 		currency_t 	not null,
    incoming 		bool_t 		not null,
    unpaid 		currency_t 	null,
    extra_info 		note_t 		null,
    primary key (account_id, erp_id)
);

create table mutuals_history_products (
    erp_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    pack_id 		uid_t 		not null,
    qty 		numeric_t 	not null,
    discount 		discount_t 	null,
    amount 		currency_t 	not null,
    primary key (erp_id, prod_id)
);

create table order_params (
    order_param_id 	uid_t 		not null primary key,
    descr 		descr_t 	not null
);

create table packs (
    pack_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    pack 		numeric_t 	not null default 1.0,
    weight 		weight_t	null,
    volume 		volume_t	null,
    "precision" 	int32_t		null,
    primary key (pack_id, prod_id)
)

create table potentials (
    poten_id 		uid_t 		not null primary key,
    descr 		descr_t 	not null
);

create table products (
    prod_id 		uid_t 		not null primary key,
    pid 		uid_t 		null,
    ftype 		ftype_t 	not null default 0,
    manuf_id 		uid_t 		null,
    brand_id 		uid_t 		null,
    categ_id 		uid_t 		null,
    code 		code_t 		null,
    descr 		descr_t 	not null,
    art 		art_t 		null,
    shelf_life 		descr_t 	null,
    obsolete 		bool_t 		null,
    novelty 		bool_t 		null,
    promo 		bool_t 		null
);

create table refunds ( /* percentage of returned products */
    account_id 		uid_t  		not null,
    prod_id    		uid_t  		not null,
    percentage 		numeric(4,1)   	not null,
    primary key (account_id, prod_id)
);

create table retail_chains (
    rc_id		uid_t		not null primary key,
    descr 		descr_t 	not null,
    ka_code		code_t		null
);

create table restrictions (
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    pack_id 		uid_t 		not null,
    min_qty 		numeric_t 	null check (min_qty is null or (min_qty >= 0)),
    max_qty 		numeric_t 	null check (max_qty is null or (max_qty >= 0)),
    primary key (account_id, prod_id)
);

create table sales_history (
    account_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    s_date 		date_t 		not null,
    amount_c 		currency_t 	null,
    pack_c_id 		uid_t 		null,
    qty_c 		int32_t 	null,
    amount_r 		currency_t 	null,
    pack_r_id 		uid_t 		null,
    qty_r 		int32_t 	null,
    extra_info 		note_t 		null,
    primary key (account_id, prod_id, s_date)
);

create table std_prices (
    prod_id 		uid_t 		not null primary key,
    pack_id 		uid_t 		not null,
    price 		currency_t 	not null
);

create table stocks_history (
    wareh_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    s_date 		date_t 		not null,
    damaged 		bool_t 		not null,
    b_qty 		int32_t 	not null default 0,
    e_qty 		int32_t 	not null default 0,
    i_qty 		int32_t 	not null default 0,
    o_qty 		int32_t 	not null default 0,
    primary key (wareh_id, prod_id, s_date, damaged)
);

create table users (
    user_id		uid_t		not null primary key,
    pid			uid_t		null,
    ftype		ftype_t		not null default 0,
    descr		descr_t		not null,
    code		code_t		null,
    role 		code_t 		null -- check (role in ('merch','sr','mr','sv','ise','cde','asm','rsm') and role = lower(role)),
);

create table warehouses (
    wareh_id 		uid_t 		not null primary key,
    descr 		descr_t 	not null
);

create table wareh_stocks (
    wareh_id 		uid_t 		not null,
    prod_id 		uid_t 		not null,
    qty 		int32_t 	not null,
    primary key (wareh_id, prod_id)
);

create table warnings (
    account_id 		uid_t 		not null,
    doc_type 		doctype_t 	not null, -- order, reclamation
    locked 		bool_t 		not null default 1,
    msg 		varchar(1024)	null,
    primary key (account_id, doc_type)
);

go


-- **** OMOBUS -> ERP streams ****


create table attributes (
    db_id 		uid_t 		not null,
    attr_id 		uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_t 		not null default current_timestamp,
    primary key (db_id, attr_id)
);

create table new_account_types (
    db_id 		uid_t 		not null,
    new_account_type_id uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_t 		not null default current_timestamp,
    primary key (db_id, new_account_type_id)
);

create table order_types (
    db_id 		uid_t 		not null,
    order_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_t 		not null default current_timestamp,
    primary key (db_id, order_type_id)
);

create table payment_methods (
    db_id 		uid_t 		not null,
    payment_method_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_t 		not null default current_timestamp,
    primary key (db_id, payment_method_id)
);

create table receipt_types (
    db_id 		uid_t 		not null,
    receipt_type_id 	uid_t 		not null,
    descr 		descr_t 	not null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_t 		not null default current_timestamp,
    primary key (db_id, receipt_type_id)
);

create table reclamation_types (
    db_id 		uid_t 		not null,
    reclamation_type_id uid_t 		not null,
    descr 		descr_t 	null,
    hidden 		bool_t 		not null default 0,
    inserted_ts 	ts_t 		not null default current_timestamp,
    primary key (db_id, reclamation_type_id)
);


create table comments (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    doc_no 		uid_t 		not null,
    user_id 		uid_t 		not null,
    dev_login 		uid_t 		not null,
    account_id 		uid_t 		not null,
    comment_type_id 	uid_t 		not null,
    doc_note 		note_t 		null,
    inserted_ts 	ts_t 		not null default current_timestamp,
    erp_id 		uid_t 		null, -- exported to the ERP
    primary key (db_id, doc_id)
);

create table new_accounts (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    doc_no 		uid_t 		not null,
    user_id 		uid_t 		not null,
    dev_login 		uid_t 		not null,
    doc_note 		note_t 		null,
    account 		descr_t 	null,
    address 		address_t 	null,
    legal_address 	address_t 	null,
    number 		code_t 		null,
    new_account_type_id uid_t 		null,
    --photo 		blob_t 		null,
    attr_ids 		uids_t 		null,
    inserted_ts 	ts_t 		not null default current_timestamp,
    erp_id 		uid_t 		null, -- exported to the ERP
    primary key (db_id, doc_id)
);

create table orders (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    doc_no 		uid_t 		not null,
    user_id 		uid_t 		not null,
    dev_login 		uid_t 		not null,
    account_id 		uid_t 		not null,
    order_type_id 	uid_t 		null,
    group_price_id 	uid_t 		null,
    wareh_id 		uid_t 		null,
    delivery_date 	date_t 		not null,
    delivery_note 	note_t 		null,
    doc_note 		note_t 		null,
    payment_method_id 	uid_t 		null,
    payment_delay 	int32_t 	null check (payment_delay is null or (payment_delay >= 0)),
    bonus 		int32_t 	null check (bonus is null or (bonus >= 0)),
    order_param_ids 	uids_t		null, /* order_params array; delimiter ',' */
    rows 		int32_t 	not null,
    prod_id 		uid_t 		not null,
    row_no 		int32_t 	not null check (row_no >= 0),
    pack_id 		uid_t 		not null,
    pack 		numeric_t 	not null,
    qty 		numeric_t 	not null,
    unit_price 		currency_t 	not null check (unit_price >= 0),
    discount 		discount_t 	not null,
    amount 		currency_t 	not null,
    weight 		weight_t 	not null,
    volume 		volume_t 	not null,
    inserted_ts 	ts_t 		not null default current_timestamp,
    erp_id 		uid_t 		null, -- exported to the ERP
    primary key (db_id, doc_id, prod_id)
);

create table receipts (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    doc_no 		uid_t 		not null,
    user_id 		uid_t 		not null,
    dev_login 		uid_t 		not null,
    account_id 		uid_t 		not null,
    receipt_type_id 	uid_t 		null,
    doc_note 		note_t 		null,
    amount 		numeric_t 	not null,
    inserted_ts 	ts_t 		not null default current_timestamp,
    erp_id 		uid_t 		null, -- exported to the ERP
    primary key (db_id, doc_id)
);

create table reclamations (
    db_id 		uid_t 		not null,
    doc_id 		uid_t 		not null,
    fix_dt 		datetime_t 	not null,
    doc_no 		uid_t 		not null,
    user_id 		uid_t 		not null,
    dev_login 		uid_t 		not null,
    account_id 		uid_t 		not null,
    return_date 	date_t 		not null,
    doc_note 		note_t 		null,
    rows 		int32_t 	not null,
    prod_id 		uid_t 		not null,
    row_no 		int32_t 	not null check (row_no >= 0),
    reclamation_type_id uid_t 		null,
    pack_id 		uid_t 		not null,
    pack 		numeric_t 	not null,
    qty 		numeric_t 	not null,
    unit_price 		currency_t 	not null check (unit_price >= 0),
    amount 		currency_t 	not null,
    weight 		weight_t 	not null,
    volume 		volume_t 	not null,
    inserted_ts 	ts_t 		not null default current_timestamp,
    erp_id 		uid_t 		null, -- exported to the ERP
    primary key (db_id, doc_id, prod_id)
);

go


-- **** System tables and procedures ****

create table symlinks (
    db_id 		uid_t 		not null,
    obj_code 		code_t 		not null, -- (product|account|user|...)
    f_id 		uid_t 		not null,
    t_id 		uid_t 		not null,
    extra_info 		note_t 		null,
    reverse 		bool_t 		not null default 1, -- 1 -> mapping table are controlled at the distributor side.
    primary key(db_id, obj_code, f_id)
);

create table sysmeta( /* without primary key */
    ext_tab 		varchar(64) 	null,
    ext_col 		varchar(64) 	null,
    int_tab 		varchar(64) 	null,
    int_col 		varchar(64) 	null,
    u 			bool_t 		not null default 0,
    i 			bool_t 		not null default 0,
    doc_type 		doctype_t 	null,
    erp_descr 		descr_t 	null
);

create table sysparams (
    param_id 		uid_t 		not null primary key,
    param_value 	uid_t 		not null,
    descr 		descr_t 	null
);

insert into sysparams values('db:id', 'L1', 'omobus-agent-db internal code.');
insert into sysparams values('gc:keep_alive', '30', 'How many days the data will be hold from cleaning.');
insert into sysparams values('ttd', 'oninsert', 'Generates TTD stream when documents inserted to the omobus-agent-db (oninsert) or to the ERP (onerpid).');
insert into sysparams values('erp:db', 'dummy', 'ERP database name.');
insert into sysparams values('erp:lock', 'false', 'Locks ERP database.');

go 

create function string_to_rowset(@string varchar(1024), @delimiter char(1))
    returns @output table(ar_value varchar(1024))
begin 
    declare @start int, @end int 
    select @start = 1, @end = CHARINDEX(@delimiter, @string) 
    while @start < LEN(@string) + 1 BEGIN 
	if @end = 0  
	    set @end = LEN(@string) + 1

	insert into @output (ar_value)
	    values(SUBSTRING(@string, @start, @end - @start))
	set @start = @end + 1 
	set @end = CHARINDEX(@delimiter, @string, @start)
    end 
    return 
end

go

create procedure sp_obj_lock
as
begin
    update sysparams set param_value='true' where param_id='erp:lock';
end

go

create procedure sp_obj_unlock
as
begin
    update sysparams set param_value='false' where param_id='erp:lock';
end

go

create function sp_obj_checklock()
    returns bool_t
as
begin
    return (select case when param_value='true' then 1 else 0 end from sysparams where param_id='erp:lock');
end

go

create procedure sp_trig_o2d
as
begin
    SET NOCOUNT ON;
    SET ANSI_PADDING ON;
    if dbo.sp_obj_checklock() > 0
	print 'ERP is locked!'
--* else
--* begin
--*	-- Write documents to the ERP.
--* end
end

go

create procedure sp_trig_d2o_highpriority
as
begin
    SET NOCOUNT ON;
    SET ANSI_PADDING ON;
    if dbo.sp_obj_checklock() > 0
	print 'ERP is locked!'
--* else
--* begin
--*	-- Read manuals from the ERP.
--* end
end

go

create procedure sp_trig_d2o_lowpriority
as
begin
    SET NOCOUNT ON;
    SET ANSI_PADDING ON;
    if dbo.sp_obj_checklock() > 0
	print 'ERP is locked!'
--* else
--* begin
--*	-- Read manuals from the ERP.
--* end
end

go
