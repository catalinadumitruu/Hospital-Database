create table Farmacii(
id_farm number(5) constraint pk_farmacii primary key,
nume varchar2(50) not null
);

create table Medicamente(
id_med number(20) constraint pk_medicamente primary key,
denumire varchar2(50) not null,
data_expirarii date not null,
tipul_de_afectiune varchar2(50) not null, --pt ce se foloseste; ex: durere de cap, ameteala, tulburari intestinale
cantitate number(5) not null,
id_farm number(5),
constraint fk_farmacii foreign key (id_farm) references Farmacii (id_farm)
);

alter table Medicamente
rename column tipul_de_afectiune to utilizare;

create table Sectii(
id_sectie number(5) constraint pk_sectii primary key,
nr_cladire number(5) not null,
etaj number(5) not null
);

create table Istoric_sectii(
id number(5) constraint pk_istoric_sectii primary key,
denumire varchar2(50) not null,
nr_paturi number(5) not null,
id_sectie number(5),
constraint fk_sectii foreign key (id_sectie) references Sectii(id_sectie)
);

alter table Istoric_sectii
drop constraint SYS_C00619685; --nume restrictie copiat din tabel

create table Pacienti(
id_pacient number(5) constraint pk_pacienti primary key,
nume varchar2(50) not null,
prenume varchar2(50) not null,
prenume_mama varchar2(50),
prenume_tata varchar2(50),
cnp char(13) not null,
data_nasterii date,
locul_nasterii varchar2(50) not null, --orasul in care s-a nascut pacientul
adresa varchar2(50),
telefon_parinte char(10),
grupa_sange varchar2(5) not null,
alergii varchar2(50),
constraint ck_adresa check (adresa like '%, %') /*punem oras, strada*/
);

alter table Pacienti
add constraint uq_cnp unique (cnp);

alter table Pacienti 
disable constraint ck_adresa; --am schimbat ulterior, pentru ca imi lua prea mult timp sa caut si strazile din orase, asa ca am lasat doar orasul


create table Saloane(
nr_camera number(5) constraint pk_saloane primary key,
nr_paturi number(5) not null,
id_sectie number(5) ,
id_pacient number(5),
constraint fkk_sectii foreign key(id_sectie) references Sectii(id_sectie),
constraint fk_pacienti foreign key (id_pacient) references Pacienti(id_pacient)
);

create table Istoric_pacienti(
data_sosirii date constraint pk_istoric_pacienti primary key,
data_plecarii date not null,
nr_zile_spitalizare number(2),
diagnostic varchar2(50),
cnp char(13) constraint uq_cnp unique, --prin cnp se identifica despre ce pacient este vorba
id_sectie number(5), --in ce sectie a fost internat la data_sosirii 
nr_camera number(5),
constraint fkk_pacienti foreign key (cnp) references Pacienti(cnp),
constraint fkkk_sectii foreign key (id_sectie) references Sectii(id_sectie),
constraint fk_saloane foreign key (nr_camera) references Saloane(nr_camera)
);

--pentru usurinta, voi face legatura cu tabela pacienti prin id, nu prin cnp
alter table istoric_pacienti
drop constraint fkk_pacienti;
alter table istoric_pacienti
drop constraint uq_cnp;
alter table Istoric_pacienti
drop column cnp cascade constraints;

alter table Istoric_pacienti
add (id_pacient number(5) );
alter table Istoric_pacienti
add constraint fkk_pacienti foreign key (id_pacient) references Pacienti(id_pacient);

alter table Istoric_pacienti
add constraint uqq_cnp unique (cnp);

alter table Istoric_pacienti
add constraint uqq_nr_camera unique (nr_camera);

alter table Istoric_pacienti
disable constraint SYS_C00619705; --nu avea sens, unii mai sunt inca internati

alter table Istoric_pacienti
drop column nr_zile_spitalizare; --se pot calcula daca e cazul, asa ca era o info in plus pe care am sters o

alter table Istoric_pacienti --am realizat ulterior ca se pot interna in aceiasi zi mai multi pacienti
drop constraint pk_istoric_pacienti;

alter table Istoric_pacienti
add constraint ck_data check (data_sosirii is not null);

alter table Istoric_pacienti
add (nr_ordine number(2) constraint pk_istoric_pacienti primary key);

create table Tratamente(
id number(5) constraint pk_tratamente primary key,
cnp_pacient char(13) constraint uqqq_cnp unique,
id_med number(20),
denumire varchar2(150) not null,
constraint fk_istoric_pacienti foreign key (cnp_pacient) references Istoric_pacienti (cnp),
constraint fk_medicamente foreign key (id_med) references Medicamente (id_med)
);


--pentru usurinta, voi face legatura cu tabela pacienti prin id, nu prin cnp
alter table tratamente
drop constraint fk_istoric_pacienti;
alter table tratamente
drop constraint uqqq_cnp;
alter table tratamente
drop column cnp_pacient cascade constraints;

alter table tratamente
add (id_pacient number(5) );
alter table tratamente
add constraint fkkk_pacienti foreign key (id_pacient) references Istoric_pacienti(nr_ordine);

create table Functii(
id_functie number(5) constraint pk_functii primary key,
denumire varchar2(50) not null,
salariul_min number(5,2) not null,
salariul_max number(10,2) not null
);

alter table functii
modify( salariul_min number(5));

alter table functii
modify( salariul_max number(10));

create table Angajati(
id_angajat number(5) constraint pk_angajati primary key,
nume varchar2(50) not null,
prenume varchar2(50) not null,
email varchar2(50), 
telefon char(10) constraint uq_telefon unique,
adresa varchar2(50),
data_angajare date not null,
stare_sanatate varchar2(10) not null,
nr_garzi number(2),
data_nasterii date not null,
id_functie number(5),
id_sectie number(5),
constraint fk_functii foreign key (id_functie) references Functii(id_functie),
constraint ck_email check (email like '%@%.%'),
constraint ckk_adresa check (adresa like '%, %'), --punem oras, strada
constraint fkkkk_sectii foreign key (id_sectie) references Sectii(id_sectie)
);

alter table Angajati
disable constraint ckk_adresa; --punem doar orasul
alter table Angajati
add (id_superior number(5));

alter table Angajati
add constraint fk_angajati foreign key(id_superior) references Angajati (id_angajat);

create table Istoric_functii(
data_inceput date constraint pk_istoric_functii primary key,
data_sfarsit date,
id_sectie number(5),
id_functie number(5),
id_angajat number(5),
constraint ffk_sectii foreign key (id_sectie) references Sectii(id_sectie),
constraint fkk_functii foreign key (id_functie) references Functii(id_functie),
constraint fk_angajat foreign key (id_angajat) references Angajati (id_angajat)
);

create table Istoric_salarii(
data_inceput date constraint pk_istoric_salarii primary key,
data_sfarsit date,
suma_salariu number(10,2) not null,
id_angajat number(5),
constraint fkk_angajati foreign key (id_angajat) references Angajati (id_angajat)
);

commit;

insert into Farmacii
values (1,'Farmacie generala');

insert into Farmacii
values (2,'Farmacie chirurgie');

insert into Farmacii
values (3,'Farmacie ORL');

insert into Farmacii
values (4,'Farmacie oftalmologie');

insert into Farmacii
values (5,'Farmacie laborator analize');

insert into Farmacii
values (6,'Farmacie dermatologie');

insert into Medicamente
values (1000,'Algocalmin', to_date('25-9-2022','dd-mm-yyyy'),'antiinflamator',151,1);

insert into Medicamente
values (1001,'Diclofenac', to_date('4-10-2025','dd-mm-yyyy'),'antiinflamator',241,1);

insert into Medicamente
values (1002,'Paracetamol', to_date('16-5-2025','dd-mm-yyyy'),'antiinflamator',29,1);

insert into Medicamente
values (1003,'Aspirina', to_date('20-01-2025','dd-mm-yyyy'),'antiinflamator',104,1);

insert into Medicamente
values (1004,'Ibuprofen', to_date('13-10-2022','dd-mm-yyyy'),'antiinflamator',219,1);

insert into Medicamente
values (1005,'Nurofen', to_date('30-9-2022','dd-mm-yyyy'),'antiinflamator',179,1);

insert into Medicamente
values (1006,'Nurofen Forte', to_date('1-12-2024','dd-mm-yyyy'),'antiinflamator',312,1);

insert into Medicamente
values (1007,'Antinevralgic Forte', to_date('23-4-2025','dd-mm-yyyy'),'antiinflamator',24,1);

insert into Medicamente
values (1008,'Furazolidon', to_date('6-11-2024','dd-mm-yyyy'),'antidiareic',410,1);

insert into Medicamente
values (1009,'Smecta', to_date('7-1-2025','dd-mm-yyyy'),'antidiareic',296,1);

insert into Medicamente
values (1010,'Ercefuryl', to_date('19-10-2022','dd-mm-yyyy'),'antidiareic',170,1);

insert into Medicamente
values (1011,'Hidrasec', to_date('17-3-2021','dd-mm-yyyy'),'antidiareic',91,1);

insert into Medicamente
values (1012,'Imodium', to_date('11-4-2021','dd-mm-yyyy'),'antidiareic',79,1);

insert into Medicamente
values (1013,'Amoxicilina', to_date('15-05-2025','dd-mm-yyyy'),'antibiotic-pentru infectii',241,1);

insert into Medicamente
values (1014,'Ampicilina', to_date('2-7-2024','dd-mm-yyyy'),'antibiotic-pentru infectii',176,1);

insert into Medicamente
values (1015,'Cefuroxim', to_date('16-7-2021','dd-mm-yyyy'),'antibiotic-pentru infectii',132,1);

insert into Medicamente
values (1016,'Gentamicina', to_date('29-1-2025','dd-mm-yyyy'),'antibiotic-pentru infectii',69,1);

insert into Medicamente
values (1017,'Oxacilina', to_date('21-2-2024','dd-mm-yyyy'),'antibiotic-pentru infectii',79,1);

insert into Medicamente
values (1018,'Zinnat', to_date('13-2-2021','dd-mm-yyyy'),'antibiotic-pentru infectii',183,1);

insert into Medicamente
values (1019,'Augumentin', to_date('30-7-2024','dd-mm-yyyy'),'antibiotic-pentru infectii',217,1);

insert into Medicamente
values (1020,'Ciprinol', to_date('14-7-2025','dd-mm-yyyy'),'antibiotic-pentru infectii',245,1);

insert into Medicamente
values (1021,'Baby Tusin', to_date('25-2-2021','dd-mm-yyyy'),'tuse',125,1);

insert into Medicamente
values (1022,'GrinTuss', to_date('11-12-2022','dd-mm-yyyy'),'tuse',145,1);

insert into Medicamente
values (1023,'Sinupret', to_date('4-11-2022','dd-mm-yyyy'),'tuse',200,1);

insert into Medicamente
values (1024,'Hexpectoral', to_date('9-10-2025','dd-mm-yyyy'),'tuse',195,1);

insert into Medicamente
values (1025,'Humisec', to_date('9-12-2021','dd-mm-yyyy'),'tuse',217,1);

insert into Medicamente
values (1026,'Tusend', to_date('23-4-2022','dd-mm-yyyy'),'tuse',77,1);

insert into Medicamente
values (1027,'Ketof', to_date('18-10-2019','dd-mm-yyyy'),'tuse',217,1);

insert into Medicamente
values (1028,'Adrenalina', to_date('22-8-2022','dd-mm-yyyy'),'stimulent',29,2);

insert into Medicamente
values (1029,'Betadine', to_date('27-1-2025','dd-mm-yyyy'),'dezinfectant',371,2);

insert into Medicamente
values (1030,'Raniseptol', to_date('14-3-2025','dd-mm-yyyy'),'dezinfectant',201,2);

insert into Medicamente
values (1031,'Dopamina', to_date('17-1-2020','dd-mm-yyyy'),'stimulent',71,2);

insert into Medicamente
values (1032,'Fenobarbital', to_date('7-7-2025','dd-mm-yyyy'),'antisepctic',100,2);

insert into Medicamente
values (1033,'Glucoza', to_date('17-2-2024','dd-mm-yyyy'),'perfuzabil',171,2);

insert into Medicamente
values (1034,'Bandaje', to_date('10-1-2028','dd-mm-yyyy'),'diverse',600,2);

insert into Medicamente
values (1035,'Plasturi', to_date('10-1-2027','dd-mm-yyyy'),'diverse',501,2);

insert into Medicamente
values (1036,'Vata', to_date('17-1-2026','dd-mm-yyyy'),'diverse',471,2);

insert into Medicamente
values (1037,'Alcool sanitar', to_date('17-1-2026','dd-mm-yyyy'),'dezinfectant',420,1);

insert into Medicamente
values (1038,'Zmax', to_date('27-4-2023','dd-mm-yyyy'),'infectii ORL',150,3);

insert into Medicamente
values (1039,'Ceroxim', to_date('20-8-2023','dd-mm-yyyy'),'infectii ORL',173,3);

insert into Medicamente
values (1040,'Azitromicina', to_date('16-11-2022','dd-mm-yyyy'),'infectii ORL',202,3);

insert into Medicamente
values (1041,'Ceftamil', to_date('2-10-2024','dd-mm-yyyy'),'infectii ORL',211,3);

insert into Medicamente
values (1042,'Cexyl', to_date('1-10-2024','dd-mm-yyyy'),'infectii ORL',72,3);

insert into Medicamente
values (1043,'Visofort', to_date('7-2-2022','dd-mm-yyyy'),'tensiune oculara',50,4);

insert into Medicamente
values (1044,'LacriSek', to_date('1-2-2019','dd-mm-yyyy'),'tensiune oculara',174,4);

insert into Medicamente
values (1045,'Nebuvis', to_date('1-2-2020','dd-mm-yyyy'),'tensiune oculara',300,4);

insert into Medicamente
values (1046,'Oftylla', to_date('2-1-2019','dd-mm-yyyy'),'tensiune oculara',87,4);

insert into Medicamente
values (1047,'Vedisan', to_date('4-5-2022','dd-mm-yyyy'),'tensiune oculara',35,4);

insert into Medicamente
values (1048,'Exudat', to_date('4-5-2022','dd-mm-yyyy'),'recipient',100,5);

insert into Medicamente
values (1049,'Coprorecoltare', to_date('1-2-2025','dd-mm-yyyy'),'recipient',100,5);

insert into Medicamente
values (1050,'Recoltor universal', to_date('1-2-2025','dd-mm-yyyy'),'recipient',100,5);

insert into Medicamente
values (1051,'Eprubete', to_date('10-10-2026','dd-mm-yyyy'),'recipient',100,5);

insert into Medicamente
values (1052,'Anse sterile', to_date('1-1-2030','dd-mm-yyyy'),'diverse',79,5);

insert into Medicamente
values (1053,'Lamele', to_date('1-1-2030','dd-mm-yyyy'),'diverse',500,5);

insert into Medicamente
values (1054,'Bepanthen', to_date('25-1-2023','dd-mm-yyyy'),'calmant',142,6);

insert into Medicamente
values (1055,'Calmiderm', to_date('11-2-2023','dd-mm-yyyy'),'calmant',48,6);

insert into Medicamente
values (1056,'Theresienol', to_date('25-1-2023','dd-mm-yyyy'),'calmant',10,6);

insert into Medicamente
values (1057,'Exoderil', to_date('14-4-2022','dd-mm-yyyy'),'antimicotic',93,6);

insert into Medicamente
values (1058,'Lamisil', to_date('6-8-2022','dd-mm-yyyy'),'antimicotic',75,6);

insert into Medicamente
values (1059,'Albastru de metilent', to_date('7-7-2019','dd-mm-yyyy'),'antiseptic',107,6);

insert into Medicamente
values (1060,'Antiseptic', to_date('23-4-2024','dd-mm-yyyy'),'antiseptic',28,6);

select count(id_med) from Medicamente;

insert into Sectii
values(1,01,4);

insert into Sectii
values(2,01,1);

insert into Sectii
values(3,02,1);

insert into Sectii
values(4,02,2);

insert into Sectii
values(5,01,2);

insert into Sectii
values(6,01,0);

insert into Sectii
values(7,01,3);

insert into Sectii
values(8,02,1);

insert into Istoric_sectii
values(1,'Pediatrie I',45,1);

insert into Istoric_sectii
values(2,'Pediatrie II',45,1);

insert into Istoric_sectii
values(3,'Pediatrie III',50,1);

insert into Istoric_sectii
values(4,'Pediatrie IV',45,1);

insert into Istoric_sectii
values(5,'Chirurgie',30,2);

insert into Istoric_sectii
values(6,'ORL',5,3);

insert into Istoric_sectii
values(7,'Oftalmologie',10,4);

insert into Istoric_sectii
values(8,'Recuperare',20,5);

insert into Istoric_sectii
values(9,'Primiri Urgente',4,6);

insert into Istoric_sectii
values(10,'Laborator',NULL,7);

insert into Istoric_sectii
values(11,'Dermatologie',10,8);

commit;

insert into Pacienti
values(1, 'Toader','Laura','Monica','Adrian',2170521034879,to_date('21-05-2017','dd-mm-yyyy'),'Pitesti','Pitesti',07154832470,'B+',NULL);

insert into Pacienti
values(2, 'Ionescu','Maria','Denisa','Eduard',2170810037741,to_date('10-08-2017','dd-mm-yyyy'),'Calinesti','Pitesti',0747154777,'0+',NULL);

insert into Pacienti
values(3, 'Petrescu','Narcis','Iulia','Dan',1160906034587,to_date('6-09-2016','dd-mm-yyyy'),'Calinesti','Pitesti',0700478744,'A+',NULL);

insert into Pacienti
values(4, 'Costache','Madalina','Daniela','Marius',2170721034879,to_date('16-07-2015','dd-mm-yyyy'),'Pitesti','Bascov',0774842100,'AB+','polen');

insert into Pacienti
values(5, 'Rizea','Marius','Mara','Cosmin',1170204038874,to_date('4-02-2017','dd-mm-yyyy'),'Bucuresti','Pitesti',0777487940,'0-','praf');

insert into Pacienti
values(6, 'Zlotea','Eliza','Mihaela','Costel',2181025031122,to_date('25-10-2018','dd-mm-yyyy'),'Bucuresti','Pitesti',0744401258,'B-',NULL);

insert into Pacienti
values(7, 'Constantin','Octavian','Mirela','Alexandru',1130420037845,to_date('20-04-2013','dd-mm-yyyy'),'Calinesti','Bascov',0758741230,'AB+',NULL);

insert into Pacienti
values(8, 'Ionita','Ada','Cosmina','Laurentiu',2180920039632,to_date('20-09-2018','dd-mm-yyyy'),'Calinesti','Pitesti',0741287459,'A+','praf');

insert into Pacienti
values(9, 'Mihalca','Andreea','Carmen','Madalin',2180101038855,to_date('1-01-2018','dd-mm-yyyy'),'Pitesti','Pitesti',0742136988,'AB-','mucegai');

insert into Pacienti
values(10, 'Bucur','Mihnea','Magda','Ion',1180509032145,to_date('9-05-2018','dd-mm-yyyy'),'Pitesti','Pitesti',0717412583,'A-',NULL);

insert into Pacienti
values(11, 'Dinu','Diana','Andreea','Silviu',2080718035500,to_date('18-07-2008','dd-mm-yyyy'),'Bucuresti','Bascov',0770011448,'B+',NULL);

insert into Pacienti
values(12, 'Tudose','Zaharia','Ioana','Dan',1141228036666,to_date('28-12-2014','dd-mm-yyyy'),'Pitesti','Pitesti',0711458790,'AB+',NULL);

insert into Pacienti
values(13, 'Predescu','Mihai','Maria','Lucian',1110305037410,to_date('5-03-2011','dd-mm-yyyy'),'Bucuresti','Pitesti',0779112244,'0+','polen');

insert into Pacienti
values(14, 'Iliescu','Mircea','Oana','Radu',1120729035556,to_date('29-07-2012','dd-mm-yyyy'),'Pitesti','Pitesti',0715784790,'B+','mucegai');

insert into Pacienti
values(15, 'Diaconu','Elena','Elena','Marius',2170830035263,to_date('30-08-2017','dd-mm-yyyy'),'Pitesti','Pitesti',0785008790,'B+',NULL);

insert into Pacienti
values(16, 'Bucur','Andreea','Ioana','David',2180509034152,to_date('9-05-2018','dd-mm-yyyy'),'Pitesti','Pitesti',0710112247,'AB+',NULL);

insert into Pacienti
values(17, 'Zamfir','Lavinia','Honoria','Silviu',2161102038520,to_date('2-11-2016','dd-mm-yyyy'),'Pitesti','Bascov',0744112298,'0-',NULL);

insert into Pacienti
values(18, 'Anghel','Cosmin','Emilia','Mircea',1150919032587,to_date('19-09-2015','dd-mm-yyyy'),'Pitesti','Bascov',0799247213,'A-',NULL);

insert into Pacienti
values(19, 'Dicu','Stefan','Amelia','Adelin',1180414032589,to_date('14-04-2018','dd-mm-yyyy'),'Pitesti','Pitesti',0711287459,'AB-',NULL);

insert into Pacienti
values(20, 'Miu','Cristina','Valeria','Cosmin',2171209038978,to_date('9-12-2017','dd-mm-yyyy'),'Bucuresti','Pitesti',0717178933,'A+','praf');

insert into Pacienti
values(21, 'Grama','Denisa','Laura','Daniel',2150904032121,to_date('4-09-2015','dd-mm-yyyy'),'Bucuresti','Pitesti',0717178930,'AB-',NULL);

insert into Pacienti
values(22, 'Cristescu','Ana','Daniela','Cristi',2171007039874,to_date('7-10-2017','dd-mm-yyyy'),'Pitesti','Bascov',0777444112,'AB+',NULL);

insert into Pacienti
values(23, 'Voica','Gabriela','Alexandra','Gabriel',2181112036593,to_date('12-11-2018','dd-mm-yyyy'),'Pitesti','Pitesti',0735544123,'A+','polen');

insert into Pacienti
values(24, 'Iordache','Georgiana','Mihaela','Matei',2141221032211,to_date('21-12-2014','dd-mm-yyyy'),'Pitesti','Pitesti',0788302175,'A+','praf');

insert into Pacienti
values(25, 'Teodoroiu','Ana','Mariana','Ovidiu',2110423035263,to_date('23-04-2011','dd-mm-yyyy'),'Calinesti','Bascov',07333318745,'B+',NULL);

insert into Pacienti
values(26, 'Dinca','Iulia','Ioana','Lucian',2120504032579,to_date('4-05-2012','dd-mm-yyyy'),'Pitesti','Pitesti',0725413098,'B-',NULL);

insert into Pacienti
values(27, 'Voicu','Andra','Maria','Stefan',2120110036541,to_date('10-01-2012','dd-mm-yyyy'),'Calinesti','Pitesti',0774125896,'B+',NULL);

insert into Pacienti
values(28, 'Dima','Monica','Adriana','Costin',2180905032189,to_date('5-09-2018','dd-mm-yyyy'),'Bucuresti','Pitesti',0771239803,'AB+',NULL);

insert into Pacienti
values(29, 'Popescu','George','Alina','Sorin',1170907036541,to_date('7-09-2017','dd-mm-yyyy'),'Calinesti','Pitesti',0758665471,'B+',NULL);

insert into Pacienti
values(30, 'Mituleci','Ilinca','Mirela','Laur',2161009035421,to_date('9-10-2016','dd-mm-yyyy'),'Pitesti','Pitesti',0700008933,'AB-',NULL);

insert into Pacienti
values(31, 'Costache','Dorian','Camelia','George',1150811032583,to_date('11-08-2015','dd-mm-yyyy'),'Pitesti','Bascov',0744425012,'A-','alimentara');

insert into Pacienti
values(32, 'Rizea','Sebastian','Dorina','Andrei',1140713032541,to_date('13-07-2014','dd-mm-yyyy'),'Calinesti','Pitesti',0789334420,'AB+',NULL);

insert into Pacienti
values(33, 'Stan','Irina','Valentina','Victor',2130619032159,to_date('19-06-2013','dd-mm-yyyy'),'Pitesti','Pitesti',0713579113,'AB+',NULL);

insert into Pacienti
values(34, 'Munteanu','Delia','Violeta','Robert',2130226034210,to_date('26-02-2013','dd-mm-yyyy'),'Pitesti','Pitesti',0720468102,'B+','polen');

commit;

insert into Pacienti
values(35, 'Coman','Emilian','Daria','Catalin',1170828036987,to_date('28-08-2017','dd-mm-yyyy'),'Pitesti','Pitesti',0700221144,'AB+',NULL);

insert into Pacienti
values(36, 'Baicu','Victoria','Elena','Liviu',2110227032513,to_date('27-02-2011','dd-mm-yyyy'),'Pitesti','Pitesti',0774125863,'B+',NULL);

--prima cifra reprezinta id-ul sectiei
--primele 2 cifre din nr_camera sunt pt nr camerei in sine
--ultima cifra pt patul din camera

insert into Saloane
values(100,3,1,1);

insert into Saloane
values(101,3,1,2);

insert into Saloane
values(102,3,1,3);

insert into Saloane
values(110,4,1,5);

insert into Saloane
values(111,4,1,6);

insert into Saloane
values(112,4,1,8);

insert into Saloane
values(113,4,1,9);

insert into Saloane
values(120,2,1,10);

insert into Saloane
values(121,2,1,15);

insert into Saloane
values(130,3,1,16);

insert into Saloane
values(131,3,1,17);

insert into Saloane
values(132,3,1,19);

insert into Saloane
values(140,3,1,20);

insert into Saloane
values(141,3,1,22);

insert into Saloane
values(142,3,1,23);

insert into Saloane
values(150,3,1,28);

insert into Saloane
values(151,3,1,29);

insert into Saloane
values(152,3,1,30);

insert into Saloane
values(160,4,1,4);

insert into Saloane
values(161,4,1,7);

insert into Saloane
values(162,4,1,12);

insert into Saloane
values(163,4,1,18);

insert into Saloane
values(170,2,1,21);

insert into Saloane
values(171,2,1,24);

insert into Saloane
values(200,2,2,11);

insert into Saloane
values(211,2,2,26);--singur in salon

insert into Saloane
values(220,2,2,31);--singur in salon, chiar daca sunt 2 paturi

insert into Saloane
values(201,2,2,32); --e in acelasi salon cu pacientul cu id-ul 11

insert into Saloane
values(300,2,3,25);

insert into Saloane
values(301,2,3,14);

insert into Saloane
values(400,2,4,27);

insert into Saloane
values(401,2,4,33);

insert into Saloane
values(500,2,5,34);

insert into Saloane
values(501,2,5,13);

insert into Saloane
values(800,2,8,35);

insert into Saloane
values(801,2,8,36);

insert into Istoric_pacienti
values(to_date('25-12-2018','dd-mm-yyyy'),to_date('29-12-2018','dd-mm-yyyy'),'bronsita',2170521034879,1,100,1); --nr de ordine la final

insert into Istoric_pacienti
values(to_date('29-12-2018','dd-mm-yyyy'),NULL,'bronsita',2170810037741,1,101,2);

insert into Istoric_pacienti
values(to_date('30-12-2018','dd-mm-yyyy'),NULL,'enterocolita',1160906034587,1,102,3);


--stergem ce am adaugat pe baza cnp-ului pt a adauga pe baza id-ului
delete from Istoric_pacienti 
where nr_camera=100;
delete from Istoric_pacienti 
where nr_camera=101;
delete from Istoric_pacienti 
where nr_camera=102;

insert into Istoric_pacienti
values(to_date('25-12-2018','dd-mm-yyyy'),to_date('29-12-2018','dd-mm-yyyy'),'bronsita',1,100,1,1); --la final: nr_ordine, id_pacient

insert into Istoric_pacienti
values(to_date('29-12-2018','dd-mm-yyyy'),NULL,'bronsita',1,101,2,2);

insert into Istoric_pacienti
values(to_date('30-12-2018','dd-mm-yyyy'),NULL,'enterocolita',1,102,3,3);

insert into Istoric_pacienti
values(to_date('14-12-2018','dd-mm-yyyy'),to_date('18-12-2018','dd-mm-yyyy'),'pneumonie',1,160,4,4);

insert into Istoric_pacienti
values(to_date('18-12-2018','dd-mm-yyyy'),to_date('24-12-2018','dd-mm-yyyy'),'enterocolita',1,110,5,5);

insert into Istoric_pacienti
values(to_date('20-12-2018','dd-mm-yyyy'),to_date('27-12-2018','dd-mm-yyyy'),'pneumonie',1,111,6,6);

insert into Istoric_pacienti
values(to_date('2-12-2018','dd-mm-yyyy'),to_date('4-12-2018','dd-mm-yyyy'),'viroza respiratorie',1,161,7,7);

insert into Istoric_pacienti
values(to_date('28-12-2018','dd-mm-yyyy'),NULL,'faringita acuta',1,112,8,8);

insert into Istoric_pacienti
values(to_date('27-12-2018','dd-mm-yyyy'),NULL,'faringita acuta',1,113,9,9);

insert into Istoric_pacienti
values(to_date('3-12-2018','dd-mm-yyyy'),to_date('5-12-2018','dd-mm-yyyy'),'varsaturi',1,120,10,10);

insert into Istoric_pacienti
values(to_date('5-12-2018','dd-mm-yyyy'),to_date('9-12-2018','dd-mm-yyyy'),'apendicita',2,200,11,11);

insert into Istoric_pacienti
values(to_date('7-12-2018','dd-mm-yyyy'),to_date('12-12-2018','dd-mm-yyyy'),'bronsita',1,162,12,12);

insert into Istoric_pacienti
values(to_date('14-12-2018','dd-mm-yyyy'),to_date('20-12-2018','dd-mm-yyyy'),'picior fracturat',5,501,13,13);

insert into Istoric_pacienti
values(to_date('25-12-2018','dd-mm-yyyy'),NULL,'otita',3,301,14,14);

insert into Istoric_pacienti
values(to_date('26-12-2018','dd-mm-yyyy'),NULL,'enterocolita',1,121,15,15);

insert into Istoric_pacienti
values(to_date('27-12-2018','dd-mm-yyyy'),NULL,'viroza respiratorie',1,130,16,16);

insert into Istoric_pacienti
values(to_date('26-12-2018','dd-mm-yyyy'),NULL,'bronsita',1,131,17,17);

insert into Istoric_pacienti
values(to_date('26-12-2018','dd-mm-yyyy'),NULL,'viroza respiratorie',1,163,18,18);

insert into Istoric_pacienti
values(to_date('26-12-2018','dd-mm-yyyy'),NULL,'enterocolita',1,132,19,19);

insert into Istoric_pacienti
values(to_date('21-12-2018','dd-mm-yyyy'),to_date('27-12-2018','dd-mm-yyyy'),'enterocolita',1,140,20,20);

insert into Istoric_pacienti
values(to_date('29-12-2018','dd-mm-yyyy'),NULL,'insuficienta respiratorie',1,170,21,21);

insert into Istoric_pacienti
values(to_date('30-12-2018','dd-mm-yyyy'),NULL,'bronsita',1,141,22,22);

insert into Istoric_pacienti
values(to_date('30-12-2018','dd-mm-yyyy'),NULL,'bronsita',1,142,23,23);

insert into Istoric_pacienti
values(to_date('29-12-2018','dd-mm-yyyy'),NULL,'viroza respiratorie',1,171,24,24);

insert into Istoric_pacienti
values(to_date('17-12-2018','dd-mm-yyyy'),to_date('18-12-2018','dd-mm-yyyy'),'otita',3,300,25,25);

insert into Istoric_pacienti
values(to_date('20-12-2018','dd-mm-yyyy'),to_date('27-12-2018','dd-mm-yyyy'),'apendicita',2,211,26,26);

insert into Istoric_pacienti
values(to_date('29-12-2018','dd-mm-yyyy'),NULL,'conjunctivita',4,400,27,27);

insert into Istoric_pacienti
values(to_date('29-12-2018','dd-mm-yyyy'),NULL,'enterocolita',1,150,28,28);

insert into Istoric_pacienti
values(to_date('27-12-2018','dd-mm-yyyy'),NULL,'pneumonie',1,151,29,29);

insert into Istoric_pacienti
values(to_date('21-12-2018','dd-mm-yyyy'),to_date('26-12-2018','dd-mm-yyyy'),'pneumonie',1,152,30,30);

insert into Istoric_pacienti
values(to_date('1-12-2018','dd-mm-yyyy'),to_date('3-12-2018','dd-mm-yyyy'),'ocluzie',2,220,31,31);

insert into Istoric_pacienti
values(to_date('10-12-2018','dd-mm-yyyy'),to_date('13-12-2018','dd-mm-yyyy'),'apendicita',2,201,32,32);

insert into Istoric_pacienti
values(to_date('14-12-2018','dd-mm-yyyy'),to_date('16-12-2018','dd-mm-yyyy'),'conjunctivita',4,401,33,33);

insert into Istoric_pacienti
values(to_date('1-12-2018','dd-mm-yyyy'),to_date('1-12-2018','dd-mm-yyyy'),'mana fracturata',5,500,34,34);

insert into Istoric_pacienti
values(to_date('2-12-2018','dd-mm-yyyy'),to_date('4-12-2018','dd-mm-yyyy'),'urticarie',8,800,35,35);

insert into Istoric_pacienti
values(to_date('28-12-2018','dd-mm-yyyy'),NULL,'urticarie',8,801,36,36);

commit;

insert into Tratamente
values(1,1015,'Cefuroxim',1);

insert into Tratamente
values(2,1015,'Cefuroxim',2);

insert into Tratamente
values(3,1014,'Ampicilina',3);

insert into Tratamente
values(4,1018,' Zinnat',4);

insert into Tratamente
values(5,1010,'Ercefuryl',5);

insert into Tratamente
values(6,1016,'Gentamicina',6);

insert into Tratamente
values(7,1005,'Nurofen',7);

insert into Tratamente
values(8,1018,' Zinnat',8);

insert into Tratamente
values(9,1018,' Zinnat',9);

insert into Tratamente
values(10,1019,'Augumentin',10);

update Tratamente
set denumire='Zinnat' where id in(4,8,9); --am facut update ul pt ca am pus din greseala un spatiu in fata si posibil sa uit de el daca fac vreun query

insert into Tratamente
values(11,1029,'Betadine',11);

insert into Tratamente
values(12,1028,'Adrenalia',12);

insert into Tratamente
values(13,1000,'Algocalmin',13);

insert into Tratamente
values(14,1017,'Oxacilina',14);

insert into Tratamente
values(15,1009,'Smecta',15);

insert into Tratamente
values(16,1022,'GrinTuss',16);

insert into Tratamente
values(17,1015,'Cefuroxim',17);

insert into Tratamente
values(18,1022,'GrinTuss',18);

insert into Tratamente
values(19,1010,'Ercefuryl',19);

insert into Tratamente
values(20,1010,'Ercefuryl',20);

insert into Tratamente
values(21,1019,'Augumentin',21);

insert into Tratamente
values(22,1028,'Adrenalia',22);

insert into Tratamente
values(23,1015,'Cefuroxim',23);

insert into Tratamente
values(24,1005,'Nurofen',24);

insert into Tratamente
values(25,1042,'Ceftamil',25);

insert into Tratamente
values(26,1029,'Betadine',26);

insert into Tratamente
values(27,1044,'LacriSek',27);

insert into Tratamente
values(28,1009,'Smecta',28);

insert into Tratamente
values(29,1016,'Gentamicina',29);

insert into Tratamente
values(30,1016,'Gentamicina',30);

insert into Tratamente
values(31,1017,'Oxacilina',31);

insert into Tratamente
values(32,1017,'Oxacilina',32);

insert into Tratamente
values(33,1044,'LacriSek',33);

insert into Tratamente
values(34,1000,'Algocalmin',34);

insert into Tratamente
values(35,1057,'Exoderil',35);

insert into Tratamente
values(36,1055,'Calmiderm',36);

insert into Functii
values(01,'medic',5000,10000);

insert into Functii
values(02,'asistent medical',3000,7000);

insert into Functii
values(03,'infirmiera',2000,4000);

insert into Functii
values(04,'paznic',2000,4000);

insert into Functii
values(05,'secretara',3000,5000);

insert into Functii
values(06,'liftier',2000,4000);

insert into Functii
values(07,'bucatareasa',2000,4000);

insert into Functii
values(08,'farmacista',5000,9000);

insert into Angajati
values(1,'Toader','Dana',NULL,0744411102,'Pitesti',to_date('14-10-1990','dd-mm-yyyy'),'buna',15,to_date('4-12-1956','dd-mm-yyyy'),01,1,NULL);

insert into Angajati
values(2,'Ceausescu','Diana','ceausescu.diana@gmail.com',0740080002,'Pitesti',to_date('14-11-1995','dd-mm-yyyy'),'buna',10,to_date('18-11-1970','dd-mm-yyyy'),01,1,NULL);

insert into Angajati
values(3,'Enescu','Georgeta','enescu.georgeta@gmail.com',0758857270,'Bascov',to_date('23-04-1995','dd-mm-yyyy'),'buna',12,to_date('4-04-1955','dd-mm-yyyy'),01,1,NULL);

insert into Angajati
values(4,'Scoroja','Simona','scoroja.simona@gmail.com',0770080002,'Pitesti',to_date('23-06-1981','dd-mm-yyyy'),'buna',15,to_date('21-01-1953','dd-mm-yyyy'),01,1,NULL);

insert into Angajati
values(5,'Vasilescu','Constanta','vasilescu.constanta@gmail.com',0780080002,'Pitesti',to_date('12-12-2000','dd-mm-yyyy'),'verificare',10,to_date('28-03-1983','dd-mm-yyyy'),01,1,NULL);

update Angajati
set id_sectie=2 
where id_angajat=5;

insert into Angajati
values(6,'Popa','Emil','popa.emil@gmail.com',0788880002,'Stefanesti',to_date('19-03-2005','dd-mm-yyyy'),'buna',12,to_date('5-03-1978','dd-mm-yyyy'),01,2,NULL);

insert into Angajati
values(7,'Zoana','Constantina','zoana.constantina@gmail.com',0774120010,'Pitesti',to_date('30-08-2004','dd-mm-yyyy'),'buna',14,to_date('23-04-1960','dd-mm-yyyy'),01,3,NULL);

insert into Angajati
values(8,'Vasilescu','Luminita',NULL,0722113365,'Pitesti',to_date('2-02-1994','dd-mm-yyyy'),'buna',15,to_date('25-02-1952','dd-mm-yyyy'),01,4,NULL);

insert into Angajati
values(9,'Enache','Valentin','enache.valentin@gmail.com',0712345678,'Pitesti',to_date('12-07-1985','dd-mm-yyyy'),'buna',10,to_date('14-07-1961','dd-mm-yyyy'),01,6,NULL);

insert into Angajati
values(10,'Stefan','Larisa','stefan.larisa@gmail.com',0348555250,'Pitesti',to_date('17-11-1993','dd-mm-yyyy'),'buna',12,to_date('3-01-1968','dd-mm-yyyy'),01,7,NULL);

insert into Angajati
values(11,'Cretu','Liuminita',NULL,0762144783,'Stefanesti',to_date('13-01-1999','dd-mm-yyyy'),'buna',14,to_date('10-05-1959','dd-mm-yyyy'),01,8,NULL);

insert into Angajati
values(12,'Popescu','Liliana','popescu.liliana@gmail.com',0348777451,'Pitesti',to_date('18-09-1999','dd-mm-yyyy'),'buna',NULL,to_date('6-05-1969','dd-mm-yyyy'),02,1,1);

insert into Angajati
values(13,'Barbulescu','Elena','barbulescu.elena@gmail.com',0758665727,'Pitesti',to_date('4-04-2004','dd-mm-yyyy'),'buna',NULL,to_date('16-07-1981','dd-mm-yyyy'),02,1,1);

insert into Angajati
values(14,'Achimescu','Ioana','achimescu.ioana@gmail.com',0741852963,'Pitesti',to_date('16-06-2009','dd-mm-yyyy'),'buna',NULL,to_date('12-08-1984','dd-mm-yyyy'),02,1,2);

insert into Angajati
values(15,'Dumitru','Dana','dumitru.dana@gmail.com',0744415025,'Pitesti',to_date('27-02-1997','dd-mm-yyyy'),'buna',NULL,to_date('17-11-1975','dd-mm-yyyy'),02,1,2);

insert into Angajati
values(16,'Mituleci','Adriana','mituleci.adriana@gmail.com',0775767812,'Pitesti',to_date('15-03-1993','dd-mm-yyyy'),'buna',NULL,to_date('7-01-1967','dd-mm-yyyy'),02,1,3);

insert into Angajati
values(17,'Vaduva','Marinela','vaduva.marinela@gmail.com',0722211149,'Pitesti',to_date('10-05-1997','dd-mm-yyyy'),'buna',NULL,to_date('26-11-1974','dd-mm-yyyy'),02,1,3);

insert into Angajati
values(18,'Ion','Daniela','ion.daniela@gmail.com',0348578987,'Pitesti',to_date('2-02-2000','dd-mm-yyyy'),'verificare',NULL,to_date('21-06-1967','dd-mm-yyyy'),02,1,4);

insert into Angajati
values(19,'Ionita','Cristina','ionita.cristina@gmail.com',0751216984,'Pitesti',to_date('17-10-1998','dd-mm-yyyy'),'buna',NULL,to_date('20-03-1974','dd-mm-yyyy'),02,1,4);

insert into Angajati
values(20,'Adamoiu','Camelia','adamoiu.camelia@gmail.com',0781245514,'Bascov',to_date('1-08-1998','dd-mm-yyyy'),'buna',NULL,to_date('27-11-1976','dd-mm-yyyy'),02,1,1);

insert into Angajati
values(21,'Mircea','Oana','mircea.oana@gmail.com',0726547807,'Stefanesti',to_date('14-10-1998','dd-mm-yyyy'),'buna',NULL,to_date('3-07-1972','dd-mm-yyyy'),02,2,5);

insert into Angajati
values(22,'Visan','Mirela','visan.mirela@gmail.com',0789874520,'Stefanesti',to_date('26-10-1991','dd-mm-yyyy'),'buna',NULL,to_date('29-01-1968','dd-mm-yyyy'),02,2,6);

insert into Angajati
values(23,'Stan','Alexandra','stan.alexandra@gmail.com',0741258001,'Stefanesti',to_date('21-01-1999','dd-mm-yyyy'),'verificare',NULL,to_date('6-12-1970','dd-mm-yyyy'),02,3,7);

insert into Angajati
values(24,'Sandulescu','Georgiana',NULL,0755548792,'Bascov',to_date('24-04-2001','dd-mm-yyyy'),'buna',NULL,to_date('19-09-1976','dd-mm-yyyy'),02,4,8);

insert into Angajati
values(25,'Ciuca','Elena','ciuca.elena@gmail.com',0748962513,'Bascov',to_date('5-12-2010','dd-mm-yyyy'),'buna',NULL,to_date('31-12-1984','dd-mm-yyyy'),02,4,8);

insert into Angajati
values(26,'Iacob','Cosmina','iacob.cosmina@gmail.com',0744887921,'Pitesti',to_date('7-10-2010','dd-mm-yyyy'),'buna',NULL,to_date('25-12-1987','dd-mm-yyyy'),02,5,6);

insert into Angajati
values(27,'Vergea','Elena','vergea.elena@gmail.com',0751575151,'Pitesti',to_date('21-12-2012','dd-mm-yyyy'),'buna',NULL,to_date('12-06-1988','dd-mm-yyyy'),02,5,5);

insert into Angajati
values(28,'Ungureanu','Antoneta','ungureanu.antoneta@gmail.com',0748454412,'Pitesti',to_date('17-09-2014','dd-mm-yyyy'),'buna',NULL,to_date('30-05-1991','dd-mm-yyyy'),02,6,9);

insert into Angajati
values(29,'Leca','Alina','leca.alina@gmail.com',0757412231,'Pitesti',to_date('10-01-2017','dd-mm-yyyy'),'buna',NULL,to_date('11-08-1988','dd-mm-yyyy'),02,6,9);

insert into Angajati
values(30,'Tudoran','Georgeta',NULL,0759987039,'Pitesti',to_date('12-02-2000','dd-mm-yyyy'),'buna',NULL,to_date('30-12-1978','dd-mm-yyyy'),02,7,10);

insert into Angajati
values(31,'Broc','Adriana','broc.adriana@gmail.com',0774521046,'Pitesti',to_date('21-03-2017','dd-mm-yyyy'),'buna',NULL,to_date('22-09-1992','dd-mm-yyyy'),02,8,11);

insert into Angajati
values(32,'Berbecaru','Lenuta',NULL,0348145791,'Pitesti',to_date('26-09-1995','dd-mm-yyyy'),'buna',NULL,to_date('26-08-1966','dd-mm-yyyy'),03,1,15);

insert into Angajati
values(33,'Florescu','Liliana',NULL,0745221398,'Bascov',to_date('20-07-1999','dd-mm-yyyy'),'buna',NULL,to_date('7-12-1966','dd-mm-yyyy'),03,1,15);

insert into Angajati
values(34,'Tinca','Georgeta',NULL,0741697841,'Pitesti',to_date('17-10-2000','dd-mm-yyyy'),'buna',NULL,to_date('9-03-1976','dd-mm-yyyy'),03,1,11);

insert into Angajati
values(35,'Boian','Monica',NULL,0721136487,'Pitesti',to_date('12-07-1987','dd-mm-yyyy'),'buna',NULL,to_date('20-02-1964','dd-mm-yyyy'),03,2,21);

insert into Angajati
values(36,'Forcea','Ionela',NULL,0748970126,'Pitesti',to_date('13-01-1989','dd-mm-yyyy'),'buna',NULL,to_date('18-12-1963','dd-mm-yyyy'),03,3,23);

insert into Angajati
values(37,'Nita','Alina',NULL,0759874223,'Pitesti',to_date('2-10-1997','dd-mm-yyyy'),'buna',NULL,to_date('23-10-1973','dd-mm-yyyy'),03,4,25);

insert into Angajati
values(38,'Firu','Rodica',NULL,0747845510,'Pitesti',to_date('1-01-1990','dd-mm-yyyy'),'buna',NULL,to_date('30-12-1970','dd-mm-yyyy'),03,5,27);

insert into Angajati
values(39,'Gaina','Felicia',NULL,0748965210,'Bascov',to_date('31-03-2006','dd-mm-yyyy'),'buna',NULL,to_date('29-07-1981','dd-mm-yyyy'),03,7,30);

insert into Angajati
values(40,'Ganea','Diana',NULL,0798662145,'Pitesti',to_date('02-09-2002','dd-mm-yyyy'),'buna',NULL,to_date('11-10-1976','dd-mm-yyyy'),03,8,31);

insert into Angajati
values(41,'Tanase','Gabriel',NULL,0348998541,'Pitesti',to_date('9-09-1999','dd-mm-yyyy'),'verificare',NULL,to_date('25-07-1969','dd-mm-yyyy'),04,1,1);

insert into Angajati
values(42,'Miu','Costel','miu.costel@gmail.com',0758921445,'Pitesti',to_date('14-02-1993','dd-mm-yyyy'),'buna',NULL,to_date('22-06-1971','dd-mm-yyyy'),04,1,2);

insert into Angajati
values(43,'Micu','Liliana','micu.liliana@gmail.com',0741126589,'Pitesti',to_date('16-07-2005','dd-mm-yyyy'),'buna',NULL,to_date('8-11-1970','dd-mm-yyyy'),05,1,3);

insert into Angajati
values(44,'Holman','Mioara','holman.mioara@gmail.com',0729136974,'Pitesti',to_date('29-11-2000','dd-mm-yyyy'),'buna',NULL,to_date('12-03-1978','dd-mm-yyyy'),06,1,4);

insert into Angajati
values(45,'Stoian','Angelica',NULL,0783689247,'Pitesti',to_date('3-08-1990','dd-mm-yyyy'),'buna',NULL,to_date('21-05-1966','dd-mm-yyyy'),07,1,1);

insert into Angajati
values(46,'Bica','Cosmina',NULL,0725793242,'Bascov',to_date('4-02-2007','dd-mm-yyyy'),'buna',NULL,to_date('25-02-1980','dd-mm-yyyy'),07,1,2);

insert into Angajati
values(47,'Manu','Mara','manu.mara@gmail.com',0785455221,'Pitesti',to_date('23-04-1998','dd-mm-yyyy'),'buna',NULL,to_date('23-06-1969','dd-mm-yyyy'),08,1,NULL);

commit;

insert into Istoric_functii
values(to_date('12.07.1987','dd-mm-yyyy'),to_date('2-02-2000','dd-mm-yyyy'),1,03,18);

insert into Istoric_functii
values(to_date('4.09.1991','dd-mm-yyyy'),to_date('15-03-1993','dd-mm-yyyy'),1,03,16);

insert into Istoric_functii
values(to_date('10-10-2004','dd-mm-yyyy'),to_date('5-12-2010','dd-mm-yyyy'),4,03,25);

insert into Istoric_functii
values(to_date('5-12-2003','dd-mm-yyyy'),to_date('4-04-2004','dd-mm-yyyy'),1,03,13);

insert into Istoric_functii
values(to_date('15-03-2016','dd-mm-yyyy'),to_date('10-01-2017','dd-mm-yyyy'),6,03,29);

insert into Istoric_salarii
values(to_date('19-10-1990','dd-mm-yyyy'),NULL,90000,1);
update istoric_salarii set suma_salariu=9000 where id_angajat=1;

insert into Istoric_salarii
values(to_date('14-11-1995','dd-mm-yyyy'),NULL,85000,2);
update istoric_salarii set suma_salariu=8500 where id_angajat=2;

insert into Istoric_salarii
values(to_date('23-04-1995','dd-mm-yyyy'),NULL,79000,3);
update istoric_salarii set suma_salariu=7900 where id_angajat=3;

insert into Istoric_salarii
values(to_date('23-06-1981','dd-mm-yyyy'),NULL,75000,4);
update istoric_salarii set suma_salariu=7500 where id_angajat=4;

insert into Istoric_salarii
values(to_date('12-12-2000','dd-mm-yyyy'),NULL,82000,5);
update istoric_salarii set suma_salariu=8200 where id_angajat=6;

insert into Istoric_salarii
values(to_date('19-03-2005','dd-mm-yyyy'),NULL,92000,6);
update istoric_salarii set suma_salariu=9200 where id_angajat=6;

insert into Istoric_salarii
values(to_date('30-08-2004','dd-mm-yyyy'),NULL,95000,7);
update istoric_salarii set suma_salariu=9500 where id_angajat=7;

insert into Istoric_salarii
values(to_date('2-02-1994','dd-mm-yyyy'),NULL,10000,8);

insert into Istoric_salarii
values(to_date('12-07-1985','dd-mm-yyyy'),NULL,79000,9);
update istoric_salarii set suma_salariu=7900 where id_angajat=9;

insert into Istoric_salarii
values(to_date('17-11-1993','dd-mm-yyyy'),NULL,60000,10);
update istoric_salarii set suma_salariu=6000 where id_angajat=10;

insert into Istoric_salarii
values(to_date('13-01-1999','dd-mm-yyyy'),NULL,9000,11);

insert into Istoric_salarii
values(to_date('18-09-1999','dd-mm-yyyy'),NULL,3500,12);

insert into Istoric_salarii
values(to_date('5-12-2003','dd-mm-yyyy'),to_date('4-04-2004','dd-mm-yyyy'),2500,13);

insert into Istoric_salarii
values(to_date('4-04-2004','dd-mm-yyyy'),NULL,3700,13);

insert into Istoric_salarii
values(to_date('16-06-2009','dd-mm-yyyy'),NULL,3500,14);

insert into Istoric_salarii
values(to_date('27-02-1997','dd-mm-yyyy'),NULL,6900,15);

insert into Istoric_salarii
values(to_date('4-09-1991','dd-mm-yyyy'),to_date('15-03-1993','dd-mm-yyyy'),3000,16);

insert into Istoric_salarii
values(to_date('15-03-1993','dd-mm-yyyy'),NULL,3600,16);

insert into Istoric_salarii
values(to_date('10-05-1997','dd-mm-yyyy'),NULL,3500,17);

insert into Istoric_salarii
values(to_date('12-07-1987','dd-mm-yyyy'),to_date('2-02-2000','dd-mm-yyyy'),2500,18);

insert into Istoric_salarii
values(to_date('2-02-2000','dd-mm-yyyy'),NULL,3500,18);

insert into Istoric_salarii
values(to_date('17-10-1998','dd-mm-yyyy'),NULL,4000,19);

insert into Istoric_salarii
values(to_date('1-08-1998','dd-mm-yyyy'),NULL,4500,20);

insert into Istoric_salarii
values(to_date('14-10-1998','dd-mm-yyyy'),NULL,3500,21);

insert into Istoric_salarii
values(to_date('26-10-1991','dd-mm-yyyy'),NULL,4000,22);

insert into Istoric_salarii
values(to_date('21-01-1999','dd-mm-yyyy'),NULL,3500,23);

insert into Istoric_salarii
values(to_date('24-04-2001','dd-mm-yyyy'),NULL,3700,24);

insert into Istoric_salarii
values(to_date('10-10-2004','dd-mm-yyyy'),to_date('5-12-2010','dd-mm-yyyy'),2700,25);

insert into Istoric_salarii
values(to_date('5-12-2010','dd-mm-yyyy'),NULL,3500,25);

insert into Istoric_salarii
values(to_date('21-12-2012','dd-mm-yyyy'),NULL,3500,26);
update istoric_salarii set data_inceput=to_date('7-10-2010','dd-mm-yyyy') where id_angajat=26;

insert into Istoric_salarii
values(to_date('21-12-2012','dd-mm-yyyy'),NULL,3500,27);

insert into Istoric_salarii
values(to_date('17-09-2014','dd-mm-yyyy'),NULL,3500,28);

insert into Istoric_salarii
values(to_date('15-03-2016','dd-mm-yyyy'),to_date('10-01-2017','dd-mm-yyyy'),2000,29);

insert into Istoric_salarii
values(to_date('10-01-2017','dd-mm-yyyy'),NULL,4000,29);

insert into Istoric_salarii
values(to_date('12-02-2000','dd-mm-yyyy'),NULL,4500,30);

insert into Istoric_salarii
values(to_date('21-03-2017','dd-mm-yyyy'),NULL,5200,31);

insert into Istoric_salarii
values(to_date('26-09-1995','dd-mm-yyyy'),NULL,3000,32);

insert into Istoric_salarii
values(to_date('20-07-1999','dd-mm-yyyy'),NULL,3000,33);

insert into Istoric_salarii
values(to_date('17-10-2000','dd-mm-yyyy'),NULL,2500,34);

insert into Istoric_salarii
values(to_date('12-07-1986','dd-mm-yyyy'),NULL,2500,35);

insert into Istoric_salarii
values(to_date('13-01-1989','dd-mm-yyyy'),NULL,3800,36);

insert into Istoric_salarii
values(to_date('2-10-1997','dd-mm-yyyy'),NULL,4000,37);

insert into Istoric_salarii
values(to_date('1-01-1990','dd-mm-yyyy'),NULL,2900,38);

insert into Istoric_salarii
values(to_date('31-03-2006','dd-mm-yyyy'),NULL,3000,39);

insert into Istoric_salarii
values(to_date('2-09-2002','dd-mm-yyyy'),NULL,2500,40);

insert into Istoric_salarii
values(to_date('9-09-1999','dd-mm-yyyy'),NULL,2500,41);

insert into Istoric_salarii
values(to_date('14-02-1993','dd-mm-yyyy'),NULL,2500,42);

insert into Istoric_salarii
values(to_date('16-07-2005','dd-mm-yyyy'),NULL,4500,43);

insert into Istoric_salarii
values(to_date('29-11-2000','dd-mm-yyyy'),NULL,2500,44);

insert into Istoric_salarii
values(to_date('3-08-1990','dd-mm-yyyy'),NULL,2500,45);

insert into Istoric_salarii
values(to_date('4-02-2007','dd-mm-yyyy'),NULL,2800,46);

insert into Istoric_salarii
values(to_date('23-04-1998','dd-mm-yyyy'),NULL,8500,47);

commit;

update istoric_salarii
set suma_salariu=8200
where id_angajat=5;

commit;

--Media de varsta rotunjita a tuturor pacientilor
SELECT Round(AVG(extract(year from sysdate)-extract(year from data_nasterii))) as "Media de varsta"
FROM pacienti;

--Sa se afiseze numele, salariul si superiorul tuturor angajatiior, pentru pozitia curenta ocupata(avand in vedere ca unii au
-- au fost promovati in timp)
SELECT initcap(a.nume) || ' ' || initcap(a.prenume) as "Nume complet", i.suma_salariu as Salariul, s.nume||' '||s.prenume as "Nume superior" 
FROM angajati a, istoric_salarii i, angajati s
WHERE a.id_superior=s.id_angajat and a.id_angajat=i.id_angajat;

--Sa se afiseze salariul mediu al unui medic
SELECT TRUNC(AVG(suma_salariu),2)
FROM istoric_salarii
WHERE id_angajat in(SELECT id_angajat
                  FROM angajati a, functii f
                  WHERE a.id_functie=f.id_functie and denumire='medic');

--Sau alta varianta :
SELECT TRUNC(AVG(suma_salariu),2) as "Salariul mediu al unui medic"
FROM istoric_salarii
WHERE id_angajat in (SELECT id_angajat
                    FROM angajati 
                    WHERE id_functie = (SELECT id_functie 
                                        FROM functii  
                                        WHERE denumire='medic'));
                                        
--Sa se afiseze medicamentele care expira in urmatoarele 2 luni
SELECT denumire
FROM medicamente
WHERE extract(month from (add_months(sysdate,2)))=extract(month from data_expirarii);

--Sa se afiseze numarul medicamentelor de care dispune fiecare farmacie de pe sectie
SELECT f.nume as Farmacie, sum(m.cantitate) as Cantitate
FROM medicamente m, farmacii f
WHERE m.id_farm=f.id_farm
GROUP BY f.nume;

--Cati copii au o varsta mai mica de 3 ani?
SELECT count(id_pacient)
FROM pacienti
WHERE extract(year from sysdate)-extract(year from data_nasterii)<=3;

--Sa se afiseze salonul in care este internat fiecare pacient
SELECT p.nume||' '||p.prenume as "Nume complet", substr(s.nr_camera,1,2)as Salon --tinand cont ca am specificat la adaugarea datelor ce reprezinta cifrele din nr_camera
FROM pacienti p, saloane s
WHERE p.id_pacient=s.id_pacient;

--Ce pacienti sufera de bronsita? Ce tratament urmeaza fiecare?
SELECT p.nume||' '||p.prenume as "Nume complet", t.denumire
FROM pacienti p, tratamente t, istoric_pacienti i
WHERE p.id_pacient=i.id_pacient and p.id_pacient=t.id_pacient and i.diagnostic='bronsita';

commit;

--Pentru toti angajatii sa se afiseze numele, salariul si un bonus, acordat astfel:
-- angajatii cu o vechime mai mare de 20 de ani---1000 lei
-- angajatii cu o vechime intre 10 si 20 de ani---500 lei, iar restul nu primesc nimic
SELECT a.nume||' ' ||a.prenume as "Nume complet",i.suma_salariu,
CASE 
WHEN extract(year from sysdate)-extract(year from a.data_angajare)>20 THEN 1000
WHEN extract(year from sysdate)-extract(year from a.data_angajare) BETWEEN 10 AND 20 THEN 500
ELSE 0 
END AS "Bonus"
FROM angajati a, istoric_salarii i
WHERE a.id_angajat=i.id_angajat;

--Sa se afiseze ne de angajati si toate sectiile disponibile
SELECT s.denumire, count(a.id_angajat)
FROM angajati a RIGHT JOIN istoric_sectii s --in caz ca exista sectii care nu au angajati
ON a.id_sectie=s.id_sectie
GROUP BY s.denumire;

--Sa se afiseze toti angajatii care au functia de infirmiera
SELECT nume||' '||prenume as "Nume complet"
FROM angajati 
WHERE id_functie= (SELECT id_functie 
                   FROM functii
                   WHERE lower(denumire)='infirmiera');
                   
--Sa se afiseze toti pacientii internati in aceiasi zi cu pacinetul Zlotea Eliza
SELECT p.nume||' ' ||p.prenume, i.data_sosirii
FROM pacienti p, istoric_pacienti i
WHERE p.id_pacient=i.id_pacient AND extract(day from data_sosirii)=(SELECT extract(day from data_sosirii)
                                                                      FROM istoric_pacienti
                                                                      WHERE id_pacient=(SELECT id_pacient FROM pacienti WHERE lower(nume)='zlotea' and lower(prenume)='eliza'));
                                                                      
--Sa se afiseze angajati,, in functie de rang
SELECT level, LPAD('** ',LEVEL)||nume||' '||prenume as "Nume complet"
FROM angajati
CONNECT BY id_superior=prior id_angajat;

--Sa se afiseze pentru fiecare functie denumirea si salariul minim 
SELECT denumire,salariul_min
FROM functii;

--Sa se calculeze pentru toti angajatii vechimea in ani, rotunjita, apoi trunchiata.
SELECT nume||' ' ||prenume as NUME,ROUND(extract(year from sysdate)-extract(year from data_angajare),2) as Vechime
FROM angajati;

SELECT nume||' ' ||prenume as NUME,TRUNC(extract(year from sysdate)-extract(year from data_angajare),2) as Vechime
FROM angajati;

--Pentru toti medicii sa se calculeze venitul, stiind ca acesta este salariul+(nr_garzilor*24)*0.20;
SELECT a.nume||' ' ||a.prenume as Nume, s.suma_salariu as Salariu,  (s.suma_salariu+(a.nr_garzi*24)*0.2) as Venit
FROM angajati a, istoric_salarii s, functii f
WHERE a.id_angajat=s.id_angajat and a.id_functie=f.id_functie and initcap(f.denumire)='Medic';

--Sa se creeze o tabela virtuala care prezinta toti angajatii care au obtinut o promovare de a lungul timpului
CREATE OR REPLACE VIEW  virtual_ang AS
SELECT a.nume||' ' ||a.prenume as "Nume complet"
FROM angajati a, istoric_functii f
WHERE a.id_angajat=f.id_angajat and a.id_angajat in( SELECT id_angajat FROM istoric_functii);

--Sa se afiseze vechiul salariul al tuturor angajatilor care au obtinut o marire
SELECT a.nume||' '||a.prenume as nume, i.suma_salariu as "salariu vechi"
FROM angajati a, istoric_salarii i
WHERE a.id_angajat=i.id_angajat and i.data_sfarsit is not null;

commit;

--Sa se creeze un cluster care are numele si prenumele angajatilor 
CREATE CLUSTER Detalii_angajati (id_tabela number(5));
CREATE TABLE nume
(
id_tabela number(5) PRIMARY KEY,
nume varchar2(50),
prenume varchar2(50)
)
CLUSTER Detalii_angajati (id_tabela);

--Sa se creeze un idex pentru numele si prenumele angajatilor
CREATE INDEX index_nume
ON angajati (nume, prenume);

--Sa se stearga indexul creat
DROP INDEX index_nume;

--Sa se faca un index pentru salariu
CREATE INDEX index_sal
ON Istoric_salarii (suma_salariu);
--Redenumeste-l Index_salariu
ALTER INDEX index_sal
RENAME TO index_salariu;

--Sa se creeze un sinonim pentru tabela angajati, dupa care sa se afiseze, pe baza sinonimului toti angajatii, mai putin cei cu id-urile 1,2,3,4,5,6,7,8,9
CREATE OR REPLACE SYNONYM Salariati for Angajati;
SELECT *
FROM Salariati
WHERE id_angajat != all(1,2,3,4,5,6,7,8,9);

CREATE SEQUENCE seq_functii
START WITH 15
INCREMENT BY 1
NOCACHE
NOCYCLE;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--                                                          PL / SQL                                                      
 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- CURSORI IMPLICITI 

-- 1 -- Sa se mareasca stocul cu 10 tuturor medicamentelor antinflamatoare
DECLARE
nr_med NUMBER(3,2);
BEGIN
update medicamente
set cantitate = cantitate+10
where utilizare = 'antiinflamator';
DBMS_OUTPUT.PUT_LINE( 'S-a marit stocul pentru '||  SQL%rowcount ||' medicamente');
END;
/

-- 2 -- Sa se modifice numarul de telefon al unui angajat pentru care id-ul se da de la tastatura
BEGIN
UPDATE angajati
SET telefon = 0744444444
WHERE id_angajat = &id_ang;
IF SQL%NOTFOUND THEN
DBMS_OUTPUT.PUT_LINE ('Nu exista angajatul cu id-ul dat.');
else DBMS_OUTPUT.PUT_LINE ('S-a facut update-ul pentru angajatul dorit.');
END IF;
END;
/

-- 3 -- Sa se selecteze numele unui pacient al carui id se d de la tastatura
DECLARE
v_numePacient pacienti.nume%type:='';
BEGIN
SELECT nume|| ' ' || prenume into v_numePacient
FROM pacienti
WHERE id_pacient = &id_p;
IF SQL%FOUND THEN DBMS_OUTPUT.PUT_LINE('S-a extras pacientul cu numele '|| v_numePacient);
END IF;
END;
/

-- 4 -- Sa se stearga medicamentele care apartin farmaciei 3 si sa se faca ROLLBACK pt a nu modifica baza de date;
BEGIN
DELETE from medicamente
WHERE id_farm=(SELECT id_farm FROM farmacii WHERE lower(nume)='farmacie orl');
DBMS_OUTPUT.PUT_LINE('S-a sters '|| SQL%ROWCOUNT || ' medicamente');
END;
/
rollback;

-- 5 -- Sa se schimbe nume angajatului cu id-ul dat de la tastatura in Mara, iar daca id ul nu exista sa se semnaleze
BEGIN
UPDATE angajati
SET prenume = 'Mara'
WHERE id_angajat = &id_ang;
IF SQL%NOTFOUND THEN 
DBMS_OUTPUT.PUT_LINE('Nu s-a gasit angajatul cautat');
ELSE DBMS_OUTPUT.PUT_LINE('S-a facut update-ul.');
END IF;
END;
/

-- CURSORI EXPLICITI

-- 1 -- Sa se afiseze medicamentele care expira in urmatoarele 2 luni
DECLARE
CURSOR c_ang IS SELECT denumire
FROM medicamente
WHERE extract(month from (add_months(sysdate,2)))=extract(month from data_expirarii);
rec_ang c_ang%rowtype;
BEGIN
open c_ang;
LOOP
EXIT WHEN c_ang%notfound;
fetch c_ang into rec_ang;
DBMS_OUTPUT.PUT_LINE('... '||rec_ang.denumire ); 
END LOOP;
DBMS_OUTPUT.PUT_LINE('Au fost selectat '|| c_ang%rowcount || ' medicamente.'); 
END;
/

-- 2 -- Lista cu angajatii care lucreaza in sectia 2;
Declare
CURSOR c_ang IS SELECT nume, prenume, data_nasterii from angajati where id_sectie = 2;
rec_ang c_ang%rowtype;
BEGIN
OPEN c_ang;
dbms_output.put_line('Angajatii din sectai 2 sunt: ');
LOOP
FETCH c_ang into rec_ang;
exit when c_ang%notfound ;
dbms_output.put_line(' --- Angajatul '||rec_ang.nume||' '|| rec_ang.prenume|| ' nascut in data de '||rec_ang.data_nasterii);
end loop;
end;
/

-- 3 -- Spitalul vrea sa faca o transfuzie de sange. Sa se afiseze toate datele despre pacinetii cu grupa B+;
DECLARE
CURSOR c_pacienti IS SELECT * FROM PACIENTI WHERE grupa_sange= 'B+';
rec_pacient c_pacienti%rowtype;
BEGIN
DBMS_OUTPUT.PUT_LINE('Pacientii care au grupa B+ sunt: ');
FOR rec_pacient in c_pacienti 
LOOP
exit when c_pacienti%notfound;
DBMS_OUTPUT.PUT_LINE('Pacientul '||rec_pacient.nume||' '||rec_pacient.prenume||'  cu CNP-ul: '|| rec_pacient.CNP||' cu alergiile: '|| rec_pacient.alergii);
END LOOP;
END;
/

-- 4 -- S? se încarce în tabela mesaje primii 5 angaja?i (id ?i nume)
BEGIN
 EXECUTE IMMEDIATE 'CREATE TABLE mesaje 
(cod varchar2(7),
nume varchar2(20)
);';
END;

DECLARE 
v_id angajati.id_angajat%type;
v_nume angajati.nume%type;
CURSOR c_ang IS SELECT id_angajat, nume FROM angajati;
BEGIN
OPEN c_ang;
FOR i IN 1..5 LOOP
FETCH c_ang INTO v_id, v_nume;
INSERT INTO mesaje VALUES(v_id, v_nume);
END LOOP;
CLOSE c_ang;
END;
/
SELECT * FROM mesaje;


-- 5 -- Sa se afiseze pentru angajat salariul -- tinand cont sa se afla in 2 tabele diferite
DECLARE
CURSOR c_sal IS SELECT a.nume, a.prenume, s.suma_salariu FROM angajati a, istoric_salarii s WHERE a.id_angajat=s.id_angajat;
v_nume angajati.nume%type;
v_prenume angajati.prenume%type;
v_salariul istoric_salarii.suma_salariu%type;
BEGIN
OPEN c_sal;
LOOP
FETCH c_sal into v_nume, v_prenume, v_salariul;
exit when c_sal%notfound;
DBMS_OUTPUT.PUT_LINE(v_nume|| ' ' ||v_prenume||' are salariul '||v_salariul);
END LOOP;
END;
/

-- EXCEPTII IMPLICITE

-- PREDEFINITE

-- 1 -- Sa se afiseze numele complet pt angajatul cu id-ul dat de la tastatura.
DECLARE
v_nume angajati.nume%type;
BEGIN
Select nume||' '|| prenume as nume_complet into v_nume
FROM angajati
where id_angajat = &id;
dbms_output.put_line(v_nume);
EXCEPTION
WHEN NO_DATA_FOUND THEN dbms_output.put_line('Nu exista un angajat cu id-ul cautat!');
END;
/

-- 2 -- Sa se afiseze data angajarii pentru angajatul al carui nume se citeste de la tastatura
DECLARE
v_DataAng angajati.data_angajare%type;
BEGIN
SELECT data_angajare into v_DataAng
FROM  angajati
WHERE prenume = '&nume';
dbms_output.put_line(v_DataAng);
EXCEPTION
WHEN TOO_MANY_ROWS THEN dbms_output.put_line('Exista mai multi angajati cu numele cautat!');
WHEN NO_DATA_FOUND THEN dbms_output.put_line('Nu exista un angajat cu numele cautat!');
END;
/

-- 3 --  Sa se afiseze denumirea medicamentelor care au un stoc mai mic de 100.
DECLARE 
CURSOR c_med IS SELECT denumire, cantitate FROM medicamente where cantitate<100;
rec_med medicamente%rowtype;
i number not null :=1;
BEGIN
dbms_output.put_line('DENUMIRE        ||       CANTITATE');
for rec_med in c_med loop
dbms_output.put_line('Medicamentul '|| i ||' ' || rec_med.denumire);
i:=i+1;
end loop;
close c_med;
EXCEPTION
WHEN INVALID_CURSOR THEN dbms_output.put_line('Operatie invalida a cursorului! El este deja inchis');
END;
/

-- NON-PREDEFINITE

-- 1 -- Sa se stearga o inregistrare din tablea istoric functii
DECLARE
eroare EXCEPTION;
PRAGMA EXCEPTION_INIT(eroare, -02292);
BEGIN
DELETE FROM functii;
EXCEPTION 
WHEN eroare THEN dbms_output.put_line('Nu se poate sterge produsul');

END;
/
rollback;

-- 2 --
DECLARE
eroare EXCEPTION;
PRAGMA EXCEPTION_INIT(eroare, -01400);
BEGIN
insert into Farmacii
values(NULL, 'farm 1');
EXCEPTION
WHEN eroare THEN dbms_output.put_line('Datele nu au fost introduse corect');
END;
/

--  EXCEPTII EXPLICITE
-- 1 -- Sa se actualizeze numele unui pacient al carui id se citeste de la tastatura
DECLARE
Exceptie EXCEPTION;
BEGIN
UPDATE PACIENTI
set nume='ADAUGAT LA UPDATE'
where id_pacient=&id;
if sql%notfound  THEN raise Exceptie;
else dbms_output.put_line('S-a facut update-ul');
END IF;
EXCEPTION
WHEN Exceptie THEN DBMS_output.put_line('Nu s-a gasit pacientul');
END;
/
ROLLBACK;

-- 2 --  Sa se extraga date despre un angajat, iar in cazul in care salariul lor este mai mic decat media, sa i se dea sal mediu
DECLARE
CURSOR c_ang IS SELECT a.nume || ' ' || a.prenume as nume_complet, i.suma_salariu
FROM angajati a, istoric_salarii i
WHERE a.id_angajat = i.id_angajat;
rec c_ang%rowtype;
avg_sal NUMBER(10,5);
exceptie EXCEPTION;
BEGIN
SELECT avg(suma_salariu) into avg_sal from istoric_salarii;

OPEN c_ang;
LOOP
fetch c_ang into rec;
BEGIN 
if rec.suma_salariu > avg_sal then dbms_output.put_line('Angajatul '||rec.nume_complet||' are  salariul: '||rec.suma_salariu);
else raise exceptie;
END IF;
EXCEPTION
WHEN exceptie then dbms_output.put_line('Salariul e mic, il facem update: '); dbms_output.put_line(' ');
                    update istoric_salarii s
                    set s.suma_salariu = avg_sal;
                    dbms_output.put_line('Angajatul '||rec.nume_complet||' are  salariul: '||rec.suma_salariu);
END;
END LOOP;
CLOSE c_ang;
END;
/

-- 3 -- Sa se afiseze toti angajatii pe departamente. Daca nu exista vreun angajat in departamentul respectiv sa se ridice o exceptie.
DECLARE
CURSOR c_dep IS SELECT denumire, id FROM istoric_sectii;
rec_dep c_dep%rowtype;
CURSOR c_ang(sectie NUMBER) IS SELECT nume||' ' || prenume as nume_complet, 
(extract(year from sysdate)-extract(year from data_angajare)) as vechime
FROM angajati
WHERE id_sectie = sectie;
TYPE rec_ang IS RECORD(
                nume angajati.nume%type,
                nrAni NUMBER(4,2)
                    );
record_ang rec_ang;
exceptie EXCEPTION;
exceptiee EXCEPTION;

BEGIN
OPEN c_dep;
LOOP
fetch c_dep into rec_dep;
exit when c_dep%notfound;        
          DBMS_OUTPUT.PUT_LINE('');
          DBMS_OUTPUT.PUT_LINE('Departamentul: '|| rec_dep.denumire);
OPEN c_ang(rec_dep.id);
LOOP
FETCH c_ang into record_ang;
exit when c_ang%notfound;
          DBMS_OUTPUT.PUT_LINE('Angajatul '|| record_ang.nume||' are o vechime de: '||record_ang.nrAni); 
          
BEGIN
if c_ang%notfound then raise exceptie;
end if;
EXCEPTION
WHEN exceptie then dbms_output.put_line('Nu mai exista angajati in sectia indicata, trecem la urmatoarea');
end;
end loop;
close c_ang;

BEGIN
if c_dep%notfound then raise exceptiee;
end if;
EXCEPTION
when exceptiee then dbms_output.put_line('Nu mai exista sectii.');
END;
end loop;
close c_dep;
END;
/

-- 4 -- Sa se puna o alergie cu un nume dat de la tastatura pentru toti pacientii al caror nume incep cu litera a
DECLARE
CURSOR c_pacienti IS SELECT nume||' '||prenume as nume_complet, alergii
FROM pacienti
WHERE lower(prenume) LIKE 'a%'
FOR UPDATE OF alergii NOWAIT;
rec_pacienti c_pacienti%rowtype;
erroor EXCEPTION;
i number(2):=1;
BEGIN
OPEN c_pacienti;
DBMS_OUTPUT.PUT_LINE('Pacientii pentru care se face update-ul sunt: ');
LOOP
FETCH c_pacienti INTO rec_pacienti;
exit when c_pacienti%notfound;
UPDATE pacienti
SET alergii = '&alergie'
WHERE CURRENT OF c_pacienti;
DBMS_OUTPUT.PUT_LINE(i||'. '||rec_pacienti.nume_complet);
i:=i+1;
END LOOP;
CLOSE c_pacienti;
END;
/
rollback;


-- Proceduri -- 

-- 1. -- Sa se construiasca o procedura ce calculeaza salariul mediu al 
-- angajatilor in functie de functia pe care acestia o detin 

CREATE OR REPLACE PROCEDURE salariul_mediu 
AS
CURSOR c_ang IS SELECT DISTINCT denumire as den, id_functie as func
                FROM functii;
CURSOR c_sal(id_func NUMBER) IS SELECT round(avg(i.suma_salariu),2) 
                                    FROM istoric_salarii i, angajati a
                                    WHERE a.id_angajat = i.id_angajat and a.id_functie = id_func;
record_ang c_ang%rowtype;
TYPE record_salariu IS RECORD(salariul_mediu istoric_salarii.suma_salariu%type);
rec_sal record_salariu;
i number := 0;
BEGIN
OPEN c_ang;
LOOP
FETCH c_ang into record_ang;
EXIT WHEN c_ang%NOTFOUND;
DBMS_OUTPUT.PUT_LINE('Functie '|| record_ang.den||': ');
OPEN c_sal(record_ang.func);
LOOP
FETCH c_sal INTO rec_sal;
EXIT WHEN c_sal%NOTFOUND;
DBMS_OUTPUT.PUT_LINE( rec_sal.salariul_mediu|| 'lei');
END LOOP;
CLOSE c_sal;
END LOOP;
CLOSE c_ang;
END;
/

EXECUTE salariul_mediu;
/

-- 2 -- Sa se afiseze situatia unui angajat printr-o procedura.
--Daca salariul acestuia este cu mult mai mic decat salariul mediu (mult mai mic = mai mic cu mai mult de 900 de lei)
-- atunci sa i se mareasca salariul cu 10%;
-- In plus, sa se defineasca exceptii pt: NO_DATA_FOUND, CURSOR nedeschis _ invalid_cursor
CREATE OR REPLACE PROCEDURE modificare_salariu (id_ang IN NUMBER)
AS
CURSOR c_ang IS SELECT * FROM angajati WHERE id_angajat = id_ang;
rec_ang c_ang%rowtype;
avg_sal istoric_salarii.suma_salariu%type;
sal_ang istoric_salarii.suma_salariu%type;
eroare EXCEPTION;
sal_modificat istoric_salarii.suma_salariu%type;

BEGIN

SELECT ROUND(AVG(suma_salariu),2) INTO avg_sal
FROM istoric_salarii;

OPEN c_ang;
LOOP
FETCH c_ang INTO rec_ang;
EXIT WHEN c_ang%NOTFOUND;
SELECT suma_salariu INTO sal_ang FROM istoric_salarii where id_angajat = rec_ang.id_angajat;

DBMS_OUTPUT.PUT_LINE('Salariul angajatului '|| rec_ang.nume||' '||rec_ang.prenume|| 'este de '|| sal_ang);

IF sal_ang + 900 < avg_sal THEN DBMS_OUTPUT.PUT_LINE('Facem update.');
                                UPDATE istoric_salarii
                                SET suma_salariu = suma_salariu + 0.1*suma_salariu
                                WHERE id_angajat = rec_ang.id_angajat;
                                SELECT suma_salariu INTO sal_modificat FROM istoric_salarii WHERE id_angajat = rec_ang.id_angajat;
                                DBMS_OUTPUT.PUT_LINE('Noul salariu este de: '|| sal_modificat|| 'lei');
else DBMS_OUTPUT.PUT_LINE('Nu este cazul sa facem update.');
END IF;

BEGIN
SELECT suma_salariu INTO sal_ang FROM istoric_salarii where id_angajat = rec_ang.id_angajat;

IF sql%NOTFOUND then raise eroare; end if;
EXCEPTION
WHEN eroare THEN DBMS_OUTPUT.PUT_LINE('Nu s-a gasit niciun angajat cu id-ul cautat');
WHEN INVALID_CURSOR THEN DBMS_OUTPUT.PUT_LINE('Cursorul nu a fost deschis!!');
END;

END LOOP;
CLOSE c_ang;
END;
/

EXECUTE modificare_salariu (23);
rollback;

EXECUTE modificare_salariu (1);


-- 3 -- o procedura care returneaza de cate ori si-a schimbat functia si implicit salariul angajatul primit ca parametru
CREATE OR REPLACE PROCEDURE nr_sal( id_ang IN NUMBER)
AS
nr number(3,2);
eroare EXCEPTION;
BEGIN
SELECT count(data_sfarsit)into nr FROM istoric_salarii WHERE id_angajat = id_ang;
if sql%found THEN DBMS_OUTPUT.PUT_LINE('Angajatul cu id-ul '|| id_ang|| ' a avut ' || nr || ' schimbari de functie.');
else RAISE eroare; 
end if;

EXCEPTION
WHEN eroare THEN DBMS_OUTPUT.PUT_LINE('Nu exista angajatul cautat.'); 
END;
/

execute nr_sal(15);
execute nr_sal(25);


-- FUNCTII 

-- 1 -- o functie care returneaza numele farmaciei in care se afla un medicament primit ca param
CREATE OR REPLACE FUNCTION med (nume_med IN VARCHAR2)
RETURN VARCHAR2
AS
denumire medicamente.denumire%type;
BEGIN
SELECT nume into denumire FROM farmacii WHERE id_farm = (SELECT id_farm FROM medicamente where denumire = nume_med);
DBMS_OUTPUT.PUT_LINE('Medicamentul ' || nume_med || ' se gaseste in ' || denumire);
return denumire;
EXCEPTION
WHEN NO_DATA_FOUND then DBMS_OUTPUT.PUT_LINE('Nu s-a gasit medicamentul cautat');
END;
/

DECLARE
nume VARCHAR2(50);
BEGIN
nume := med('Algocalmin');
--DBMS_OUTPUT.PUT_LINE(nume);
END;
/

DECLARE
nume VARCHAR2(50);
BEGIN
nume := med('Zmax');
END;
/

DECLARE
nume VARCHAR2(50);
BEGIN
nume := med('Zx');
END;
/

-- 2 -- O functie care sa verifice daca angajatul are un salariu mai mare decat sal mediu din spital
CREATE OR REPLACE FUNCTION verificare (id_ang IN NUMBER)
RETURN BOOLEAN
AS
avg_sal istoric_salarii.suma_salariu%type;
sal_ang istoric_salarii.suma_salariu%type;
BEGIN
SELECT round(avg(suma_salariu)) into avg_sal
FROM istoric_salarii;

SELECT suma_salariu INTO sal_ang 
FROM istoric_salarii
 WHERE id_angajat = id_ang;
 
 if sal_ang > avg_sal THEN RETURN TRUE;
 ELSE RETURN FALSE;
 END IF;
 
 EXCEPTION
 WHEN NO_DATA_FOUND then DBMS_OUTPUT.PUT_LINE('Nu exista angajatul cautat');
END;
/

BEGIN
IF (verificare(15) IS NULL) THEN DBMS_OUTPUT.PUT_LINE('Nu exista angajatul cautat.');
elsif (verificare(15)) THEN DBMS_OUTPUT.PUT_LINE('Angajatul are salariul mai mare decat media.Felicitari.');
else DBMS_OUTPUT.PUT_LINE('Angajatul NU are salariul mai mic decat media. ');
END IF;
END;
/

BEGIN
IF (verificare(78) IS NULL) THEN DBMS_OUTPUT.PUT_LINE('Nu exista angajatul cautat.');
elsif (verificare(78)) THEN DBMS_OUTPUT.PUT_LINE('Angajatul are salariul mai mare decat media.Felicitari.');
else DBMS_OUTPUT.PUT_LINE('Angajatul NU are salariul mai mic decat media. ');
END IF;
END;
/

-- 3 -- Sa se returneze printr-o functie stocul pentru un medicament dat de la tastatura
CREATE OR REPLACE FUNCTION stoc (med IN VARCHAR2)
RETURN NUMBER
AS
cantitate_med medicamente.cantitate%type;

BEGIN
SELECT cantitate INTO cantitate_med
FROM medicamente
WHERE denumire = med;
 DBMS_OUTPUT.PUT_LINE('Medicamentul ' ||med||' are in stoc '|| cantitate_med ||' bucati');
return cantitate_med;

EXCEPTION
when NO_DATA_FOUND THEN
       dbms_output.put_line('Nu exista medicamentul cautat');
END;
/

DECLARE
cantitate medicamente.cantitate%type;
BEGIN
cantitate := stoc('Ketof');
END;
/

DECLARE
cantitate medicamente.cantitate%type;
BEGIN
cantitate := stoc('Nurofen');
END;
/

DECLARE
cantitate medicamente.cantitate%type;
BEGIN
cantitate := stoc('Tussin');
END;
/

-- 4 -- O functie care sa returneze nr de pacienti dintr-un salon dat ca parametru
--Potrivit proiectului din sem 1 : prima cifra din nr salonului reprezinta id-ul sectiei,
--primele 2 cifre din nr_camera sunt pt nr camerei in sine,
--ultima cifra pt patul din camera
CREATE OR REPLACE FUNCTION nr_pacienti(nr_salon IN NUMBER)
RETURN number
AS
nr_pacienti NUMBER(2);
eroare EXCEPTION;
BEGIN
SELECT count(id_pacient) into nr_pacienti
FROM saloane
WHERE substr(nr_camera,1,2) = nr_salon;
DBMS_OUTPUT.PUT_LINE('In salonul '|| nr_salon||' sunt '|| nr_pacienti||' pacienti.');
If sql%rowcount = 0 then raise eroare; 
end if;
return nr_pacienti;
EXCEPTION 
when NO_DATA_FOUND then DBMS_OUTPUT.PUT_LINE('Salonul introdus nu este valid');
when eroare then DBMS_OUTPUT.PUT_LINE('Salonul introdus nu este valid');
END;
/

DECLARE 
salon NUMBER(2);
BEGIN
salon := nr_pacienti(10);
END;
/

DECLARE 
salon NUMBER(2);
BEGIN
salon := nr_pacienti(100);
END;
/

--Afisam nr de pacienti din fiecare salon: 
DECLARE
CURSOR c_pacienti IS SELECT DISTINCT substr(nr_camera,1,2) as nr from saloane;
nr_p NUMBER(2);
BEGIN
FOR rec IN c_pacienti LOOP
nr_p := nr_pacienti(rec.nr);
END LOOP;
END;
/


-- TRIGGERS 

-- 1 -- Sa se creeze un trigger care sa nu permita adaugarea unui nou pacient intr-un salon a carui capacitate este deja atinsa.
--prima cifra reprezinta id-ul sectiei
--primele 2 cifre din nr_camera sunt pt nr camerei in sine
--ultima cifra pt patul din camera

create or replace TRIGGER check_salon  
BEFORE INSERT
ON saloane
FOR EACH ROW
DECLARE
nr_pacienti NUMBER(2);
BEGIN
SELECT count(id_pacient) INTO nr_pacienti
FROM saloane
WHERE substr(nr_camera,0,2) =  substr(:new.nr_camera,0,2);

if nr_pacienti > :new.nr_paturi then RAISE_APPLICATION_ERROR(-20700, 'The room is already full');
END IF;
END;
/

insert into saloane
Values(103, 3, 1, 38);

-- 2 --Sa se creeze un trigger care :
--- a) sa nu permita inserarea unui pacient fara sa aiba o alergie trecuta sau daca nu, sa se scrie 'fara alergii'
--- b) sa nu permita modificarea grupei de sange;

create or replace TRIGGER control_pacienti
BEFORE INSERT OR UPDATE OF grupa_sange
ON pacienti 
FOR EACH ROW
BEGIN
IF INSERTING THEN 
    IF :new.alergii is NULL THEN 
                    RAISE_APPLICATION_ERROR(-20010,'Cannot be inserted.');
    end if;
ELSIF UPDATING then
      raise_application_error(-20100,'Nu se poate face update pe grupa de sange');     
end if;       
END;
/

insert into pacienti
values(38,'Pacient','NOU','prenume mama','prenume tata',2980422035265,to_date('23-04-2018','dd-mm-yyyy'),'Pitesti','Bucuresti',0754784521,'B+',NULL);

insert into pacienti
values(38,'Pacient','NOU','prenume mama','prenume tata',2980422035265,to_date('23-04-2018','dd-mm-yyyy'),'Pitesti','Bucuresti',0754784521,'B+','fara alergii');

update pacienti
set grupa_sange ='A'
where id_pacient =10;


-- 3 -- Sa se creeze un trigger care sa genereze id ul angajatilor noi
CREATE SEQUENCE  gen_id2
MINVALUE 1 MAXVALUE 1000 
INCREMENT BY 1 
START WITH 68 
CACHE 20
NOORDER  NOCYCLE ;

create or replace TRIGGER generate_id
BEFORE INSERT
ON ANGAJATI
FOR EACH ROW
BEGIN
SELECT gen_id2.nextval INTO :new.id_angajat FROM dual;
END;
/

INSERT INTO angajati (nume,prenume,email,telefon,adresa,data_angajare,stare_sanatate,nr_garzi,data_nasterii,id_functie,id_sectie,id_superior)
VALUES('Angajat NOU','01','angajat.nou@yahoo.com',0741258723,'Pitesti',to_date('12-12-2012','dd-mm-yyyy'),'buna',2,to_date('23-04-1990','dd-mm-yyyy'),1,2,NULL);

-- 4 --  Sa se creeze un trigger care sa nu permita adaugarea unor medicamente expirate

create or replace TRIGGER med
BEFORE INSERT
ON MEDICAMENTE
FOR EACH ROW
BEGIN
 if extract(year from :new.data_expirarii) < extract(year from sysdate) THEN 
                      RAISE_APPLICATION_ERROR(-20999,'Nu se poate introduce un medicament expirat');
end if;
END;
/

INSERT INTO medicamente
values (1254,'MedTEST',to_date('1-10-2017','dd-mm-yyyy'),'antiinflamator',12,1);

-- 5 -- Sa se creeze un trigger care sa nu permita micsorarea salariului unui angajat care a avut cel putin 2 functii
create or replace TRIGGER modify_sal
BEFORE UPDATE
OF SUMA_SALARIU
ON ISTORIC_SALARII
FOR EACH ROW
DECLARE 
nr_functii NUMBER(2);
BEGIN
SELECT count(data_sfarsit) into nr_functii
FROM istoric_functii
where id_angajat = :new.id_angajat;

if :new.suma_salariu < :old.suma_salariu THEN
        if nr_functii >= 1 THEN   --count nu numarul valorile null asa ca daca angajatul a avut o singura functie => count = 0 
                                  -- daca a aviut 2 functii atunci count va returna 1
        RAISE_APPLICATION_ERROR(-20005, 'Nu se poate miscora salariul unui angajat care a avut cel putin 2 functii.');  
        end if;
END IF;           
END;
/

update istoric_salarii
SET suma_salariu = suma_salariu - 100
WHERE id_angajat = 13;

update istoric_salarii
SET suma_salariu = suma_salariu - 100
WHERE id_angajat = 17;

rollback;

-- 6 -- Un trigger care sa nu permita marirea salariului angajatilor care au o vechime mai mica de 5 ani
create or replace trigger update_ang
BEFORE UPDATE
OF SUMA_SALARIU
ON ISTORIC_SALARII
FOR EACH ROW
DECLARE
d_ang angajati.data_angajare%type;
BEGIN
SELECT data_angajare into d_ang
FROM angajati 
where id_angajat = :new.id_angajat;
if (sysdate - d_ang)/365 <= 5 then
      if :new.suma_salariu > :old.suma_salariu then
        RAISE_APPLICATION_ERROR(-20001,'The sal is bigger that the initial one');
        else dbms_output.put_line('The salary was updated');
      end if;
end if;
END;
/

update istoric_salarii
SET suma_salariu = suma_salariu + 100
WHERE id_angajat = 29;

-- 7 -- TRIGGER CU INSTEAD OF
-- sa se construiasca un trigger care:
-- A. atunci cand se va adauga un client in info_angajati, acesta se va adauga de fapt in angajati
--B. la stergerea unui angajat din info_ang se va sterge de fapt din angajati
--c. la modificarea salariului din info_ang se va modifica de fapt in istoric_salarii
CREATE OR REPLACE VIEW info_angajati AS
SELECT a.id_angajat,a.nume, a.prenume ,a.data_angajare,a.stare_sanatate,a.data_nasterii,f.denumire,s.suma_salariu
FROM angajati a, functii f, istoric_salarii s
WHERE a.id_angajat = s.id_angajat and a.id_functie = f.id_functie;

CREATE OR REPLACE TRIGGER instead_of_trigger 
INSTEAD OF UPDATE OR DELETE OR INSERT
ON info_angajati
FOR EACH ROW 
BEGIN
IF INSERTING THEN
                  INSERT INTO angajati(id_angajat,nume,prenume,data_angajare,stare_sanatate,data_nasterii)
                  VALUES (:new.id_angajat,:new.nume,:new.prenume,:new.data_angajare,:new.stare_sanatate,:new.data_nasterii);
                  INSERT INTO istoric_salarii(data_inceput,suma_salariu,id_angajat)
                  VALUES(sysdate,:new.suma_salariu,:new.id_angajat);
ELSIF DELETING THEN 
                  DELETE FROM angajati
                  WHERE id_angajat = :old.id_angajat;
                  DBMS_OUTPUT.PUT_LINE('DFD');
ELSIF UPDATING('suma_salariu') THEN
                  UPDATE istoric_salarii
                  SET suma_salariu = :new.suma_salariu
                  WHERE id_angajat = :old.id_angajat;
ELSIF UPDATING('nume') THEN
                 UPDATE angajati
                 SET nume = :new.nume
                 WHERE id_angajat = :old.id_angajat;
END IF;
END;
/

INSERT INTO info_angajati
VALUES(100,'Angajat','Nou',to_date('12-05-2019','dd-mm-yyyy'),'buna',to_date('23-09-1990','dd-mm-yyyy'),'medic',5601);

DELETE FROM INFO_angajati
WHERE id_angajat = 47;

UPDATE info_angajati
SET suma_salariu = 10000
WHERE id_angajat = 46;

 -- PACKAGE --
 --Sa se creeze un pachet care sa contina:
 -- a) o procedura care sa afiseze date despre un angajat : prin BULK COLLECT
 -- b) o procudura care sa afiseze numele, salariul, denumirea sectiei si numele superiorului angajatului
 -- c) o functie care sa calculeze suma taxelor datorate de angajatul primit ca parametru
 -- d) o procedura care sa afiseze angajatii care platesc taxe mai mare decat o suma primita ca param
 -- e) o functie care sa returneze nr de garzi ale unui angajat
 CREATE OR REPLACE PACKAGE package_ang AUTHID CURRENT_USER IS
PROCEDURE print_info_ang;
PROCEDURE print_ang_details(id_ang IN NUMBER);
FUNCTION tax_ang(id_ang IN NUMBER) RETURN NUMBER;
PROCEDURE ang_cu_taxe_mari(summ IN NUMBER);
END;
/

CREATE OR REPLACE PACKAGE BODY package_ang IS
TYPE ang_table IS TABLE OF angajati%rowtype INDEX BY BINARY_INTEGER;
table_ang ang_table;

FUNCTION nr_garzi_ang (id_anga IN NUMBER) RETURN NUMBER IS  -- functie privata, nu poate fi apelata decat din pachet;
nr_g NUMBER(2,0);
BEGIN
SELECT nr_garzi INTO nr_g
FROM ANGAJATI
WHERE id_angajat =  id_anga;
if nr_g IS NOT NULL THEN RETURN nr_g;
else RETURN 0;
END IF;
END;

PROCEDURE print_info_ang IS
BEGIN
SELECT * BULK COLLECT INTO table_ang
FROM angajati;
FOR i IN table_ang.FIRST..table_ang.LAST LOOP
        IF table_ang.EXISTS(i) THEN
        DBMS_OUTPUT.PUT_LINE('->'||table_ang(i).nume || ' ' ||table_ang(i).prenume||' ' ||table_ang(i).adresa);
        end IF;
END LOOP;
END;

PROCEDURE print_ang_details(id_ang IN NUMBER) IS
CURSOR cursor_ang  IS SELECT a.nume||' '||a.prenume as Nume_angajat, i.suma_salariu as Salariul, s.denumire as Sectie, sup.nume||' '||sup.prenume as Nume_superior
                      FROM angajati a, istoric_salarii i, istoric_sectii s, angajati sup
                      WHERE a.id_angajat =  i.id_angajat and a.id_sectie =  s.id_sectie and a.id_superior = sup.id_angajat and a.id_Angajat= id_Ang; 
BEGIN
FOR ang_rec IN cursor_ang LOOP
EXIT WHEN cursor_ang%NOTFOUND;
if ang_Rec.Nume_superior is NULL then
ang_Rec.Nume_superior := 'NU exista';  
DBMS_OUTPUT.PUT_LINE('Nume angajat '||ang_rec.Nume_angajat||', salariu: '||ang_rec.Salariul||' LEI, sectia: '|| ang_rec.Sectie|| ', nume superior: '||ang_Rec.Nume_superior);
else DBMS_OUTPUT.PUT_LINE('Nume angajat '||ang_rec.Nume_angajat||', salariu: '||ang_rec.Salariul||' LEI, sectia: '|| ang_rec.Sectie|| ', nume superior: '||ang_Rec.Nume_superior);
end if;
END LOOP;
END;

FUNCTION tax_ang(id_ang IN NUMBER) RETURN NUMBER IS -- putem sa p facem si privata, prin stergerea declaratiei ei din specificatii
tax_sum NUMBER(10,5);                               -- in acest mod nu mai putem sa apelam decat in cadrul subprogramului
sum NUMBER(10,5);
sal istoric_salarii.suma_salariu%type;
imp istoric_salarii.suma_salariu%type; 
sal_imp istoric_salarii.suma_salariu%type; 
BEGIN
SELECT suma_salariu INTO sal FROM istoric_salarii WHERE id_angajat = id_ang;
imp :=0.25*sal + 0.1*sal;
sal_imp := sal - imp;
tax_sum := 0.1*sal_imp;
sum := tax_sum + imp;
RETURN tax_sum;
END;

PROCEDURE ang_cu_taxe_mari(summ IN NUMBER) IS
CURSOR c_dep IS SELECT id_sectie, denumire FROM istoric_Sectii;
CURSOR c_Ang(c_Depart NUMBER) IS SELECT id_angajat, nume||' '||prenume as nume, telefon, data_angajare FROM angajati WHERE id_sectie = c_Depart; 
TYPE dep_record IS RECORD ( id_sectie istoric_sectii.id_sectie%type,
                         denumire istoric_sectii.denumire%type);
dep_rec dep_record;     
TYPE ang_record IS RECORD ( id_angajat angajati.id_angajat%type,
                            nume angajati.nume%type,
                            telefon angajati.telefon%type,
                            data_angajare angajati.data_angajare%type);
ang_rec ang_record;
--EROARE exception;
tax NUMBER(10,5);
BEGIN
OPEN c_dep;
LOOP
FETCH c_dep INTO dep_rec;
EXIT WHEN c_dep%NOTFOUND;
DBMS_OUTPUT.PUT_LINE('Departamentul: '|| dep_rec.denumire);   
    OPEN c_ang(dep_rec.id_sectie);
    LOOP
    FETCH c_Ang INTO ang_Rec;
    EXIT WHEN c_Ang%NOTFOUND;
    tax := package_ang.tax_ang(ang_Rec.id_angajat);
    if  tax >= summ THEN
    DBMS_OUTPUT.PUT_LINE('NUME:  '||ang_Rec.nume|| ', telefon:  '||ang_Rec.telefon||', data de angajare:   '||ang_Rec.data_angajare||' TAXE: '||tax);
    end if;
    END LOOP;
    CLOSE c_Ang;
END LOOP;
close c_dep;
END;

END;
/

DECLARE
tax_sum NUMBER(10,5);
nr_GARZI NUMBER(2,0);
BEGIN
package_ang.print_info_ang;
package_ang.print_ang_details(15);
tax_sum := package_ang.tax_ang(15);
DBMS_OUTPUT.PUT_LINE('Angajatul plateste taxe in valoare de: '||tax_sum||' lei.');
package_ang.ang_cu_taxe_mari(500);
END;
/

---------------------------------------------------------------------------------------------------------------------------------------
--                                           PROBLEMA COMPLEXA
---------------------------------------------------------------------------------------------------------------------------------------
-- A. Sa se creeze o tabela info_pacienti, cu structura nume VARCHAR2(50), salon NUMBER(5), grupa_sange VARCHAR2(5),denumire_sectie VARCHAR2(50)
-- ATENTIE! conform specificatiilor din baza de date creata anterior,cifrele din nr camerei reprezinta: 
--prima cifra reprezinta id-ul sectiei
--primele 2 cifre din nr_camera sunt pt nr camerei in sine
--ultima cifra pt patul din camera

--B. Intr-un pachet:
-- I. Sa se construiasca o functie privata care returneaza numarul total de pacienti
-- II. Sa se construiasca o procedura care sa returneze pacientii care inca nu sunt externati si sa se adauge in tabela mai sus creata
-- III. Sa se construiasca o procedura care sa realizeze o statistica a pacientilor:
--  <> cat % sunt internati pe sectia pediatrie?
--  <> cat % sufera de alergii?
--  <> cati pacienti sunt inca internti? (sa se foloseasca procedura anterior definita pentru a extrage nr de pacienti)
--  <> procente pe diagnostic


-- A. Implementare cerinta:
BEGIN
EXECUTE IMMEDIATE 'CREATE TABLE infoo_pacienti(
nr_ordine NUMBER(5) constraint pkk_info_p PRIMARY KEY,
id_pacient NUMBER(5),
nume VARCHAR2(50),
salon NUMBER(5),
grupa_sange VARCHAR2(5)NOT NULL,
denumire_sectie VARCHAR2(50)
)';
END;
/
--drop table infoo_pacienti;

--B. Implementare
BEGIN
EXECUTE IMMEDIATE 'CREATE OR REPLACE VIEW view_aux AS
                SELECT count(id_pacient) AS bolnavi,diagnostic
                FROM istoric_pacienti
                GROUP BY diagnostic';
END;
/

CREATE OR REPLACE PACKAGE package_pacienti IS
--FUNCTION total_pacienti RETURN NUMBER;
PROCEDURE pacienti_neexternati(pacienti OUT SYS_REFCURSOR);
PROCEDURE statistici_pacienti(internati_pediatrie OUT NUMBER, alergici OUT NUMBER, internati OUT NUMBER,procente_bolnavi OUT SYS_REFCURSOR);
END;
/

CREATE OR REPLACE PACKAGE BODY package_pacienti IS

FUNCTION total_pacienti RETURN NUMBER IS
numar_total_pacienti NUMBER(10,0);
BEGIN
SELECT count(id_pacient) INTO numar_total_pacienti
FROM pacienti;
return numar_total_pacienti;
END;


PROCEDURE pacienti_neexternati(pacienti OUT SYS_REFCURSOR) IS
data_plecare_pacient istoric_pacienti.data_plecarii%type;
CURSOR nu_stiu IS SELECT p.id_pacient,i.id_sectie,ip.data_plecarii,p.nume||' '||p.prenume as nume, substr(s.nr_camera,0,2) as salon,p.grupa_sange,i.denumire
                  FROM pacienti p, saloane s, istoric_sectii i, istoric_pacienti ip
                  WHERE p.id_pacient = s.id_pacient and s.id_sectie = i.id_sectie and p.id_pacient = ip.id_pacient and i.id_sectie = ip.id_sectie;
nr_ordine NUMBER(5) := 0;
TYPE bulk_collecton IS TABLE OF infoo_pacienti.id_pacient%TYPE; 
ok Boolean := true;
vector bulk_collecton;

BEGIN
OPEN pacienti FOR SELECT p.id_pacient,p.nume||' '||p.prenume as nume, substr(s.nr_camera,0,2),p.grupa_sange,i.denumire
                  FROM pacienti p, saloane s, istoric_sectii i, istoric_pacienti ip
                  WHERE p.id_pacient = s.id_pacient and s.id_sectie = i.id_sectie and p.id_pacient = ip.id_pacient and ip.data_plecarii IS NULL;
                  
FOR rec_pacienti IN nu_stiu LOOP
       EXIT WHEN nu_stiu%NOTFOUND;
       IF rec_pacienti.data_plecarii IS NULL THEN
        SELECT id_pacient BULK COLLECT INTO vector
        FROM infoo_pacienti;
        
        ok := true;
        
        FOR i in 1..vector.count LOOP
           IF vector(i) = rec_pacienti.id_pacient THEN ok := false;
           END IF;
        END LOOP;
        IF OK = TRUE THEN 
                                  INSERT INTO infoo_pacienti(nr_ordine,id_pacient,nume,salon,grupa_sange,denumire_sectie)
                                  VALUES(nr_ordine,rec_pacienti.id_pacient,rec_pacienti.nume, rec_pacienti.salon, rec_pacienti.grupa_sange, rec_pacienti.denumire);
                                  nr_ordine := nr_ordine + 1;
                                  END IF;
       END IF;
END LOOP;
END;

PROCEDURE statistici_pacienti(internati_pediatrie OUT NUMBER, alergici OUT NUMBER, internati OUT NUMBER,procente_bolnavi OUT SYS_REFCURSOR) IS
nr_pacienti NUMBER(10,0) :=  total_pacienti;
nr_pacienti_pediatrie NUMBER(10,0);
nr_alergici NUMBER(10,0);
nr_internati NUMBER(10,0);

--CURSOR diagnostic IS SELECT distinct(diagnostic)
--                     FROM istoric_pacienti;
--rec_diag diagnostic%rowtype;


TYPE vect IS TABLE OF istoric_pacienti.diagnostic%Type;
vectorDiag vect;
BEGIN
SELECT count(id_pacient) into nr_pacienti_pediatrie
FROM istoric_pacienti
WHERE id_sectie in (SELECT id_sectie FROM istoric_sectii WHERE lower(denumire) like '%pediatrie%');
internati_pediatrie := (nr_pacienti_pediatrie/nr_pacienti)*100;

SELECT count(id_pacient) INTO nr_alergici
FROM pacienti
WHERE alergii IS NOT NULL;
alergici := (nr_alergici/nr_pacienti)*100;

SELECT count(id_pacient) INTO nr_internati
FROM istoric_pacienti
WHERE data_plecarii IS NULL;
internati := (nr_internati/nr_pacienti)*100;
  
SELECT distinct(diagnostic) BULK COLLECT INTO vectorDiag
FROM istoric_pacienti;

--FOR i in 1..vectorDiag.count LOOP DBMS_OUTPUT.PUT_LINE(vectorDiag(i)); END LOOP;

---FOR i in 1..vectorDiag.count LOOP
      OPEN procente_bolnavi FOR  SELECT round((bolnavi/nr_pacienti)*100,2), diagnostic
                                 FROM view_aux;
                                -- WHERE diagnostic = vectorDiag(i);
--END LOOP;
END;

END;
/


DECLARE
first_cursor SYS_REFCURSOR;
TYPE first_recordd IS RECORD(id_pacient infoo_pacienti.nr_ordine%type,
                            nume infoo_pacienti.nume%type,
                            salon infoo_pacienti.salon%type,
                            grupa_sange infoo_pacienti.grupa_sange%type,
                            denumire_sectie infoo_pacienti.denumire_sectie%type);
first_record first_recordd;
i NUMBER(10) := 1;
internati_pediatrie NUMBER(10);
alergici NUMBER(10);
internati NUMBER(10);
second_cursor SYS_REFCURSOR;
TYPE sec_record IS RECORD(numar NUMBER(10,5),
                           diagnostic istoric_pacienti.diagnostic%type);
second_record sec_record;
BEGIN
package_pacienti.pacienti_neexternati(first_cursor);
DBMS_OUTPUT.PUT_LINE('###### Pacientii care sunt inca internati sunt: ');
IF first_cursor IS NOT NULL THEN LOOP
        FETCH first_cursor INTO first_record;
        EXIT WHEN first_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(i||'.Nume: '||first_record.nume||' se afla in salonul '||first_record.salon||' are grupa de sange '
        || first_record.grupa_sange|| ' si se afla internat in sectia: '|| first_record.denumire_sectie);
        i := i + 1;
    END LOOP;
END IF;
DBMS_OUTPUT.PUT_LINE('<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>');
package_pacienti.statistici_pacienti(internati_pediatrie,alergici,internati,second_cursor);
DBMS_OUTPUT.PUT_LINE('<>   '||internati_pediatrie||'% din pacienti sunt internati pe sectia Pediatrie.');
DBMS_OUTPUT.PUT_LINE('<>   '||alergici||'% din pacienti sunt alergici la ceva.');
DBMS_OUTPUT.PUT_LINE('<>   '||internati||'% din pacienti sunt inca internati.');
DBMS_OUTPUT.PUT_LINE('<>  Statistici pe categorii de boli: ');
IF second_cursor IS NOT NULL THEN LOOP
         FETCH second_cursor INTO second_record;
         EXIT WHEN second_cursor%NOTFOUND;
         DBMS_OUTPUT.PUT_LINE(' ----- '||second_record.numar||'% au diagnosticul -> '||second_record.diagnostic);
    END LOOP;
 END IF;
END;
/

--C. Sa se creeze o procedura ascunsa, care ofera date statistice despre angajati:
-- <> salariul mediu pe departamente 
-- <> numarul de angajati pe departamente

CREATE OR REPLACE PROCEDURE hidden_proc IS
CURSOR c_dep IS SELECT id_sectie, denumire
                FROM istoric_sectii;
rec_dep c_dep%rowtype;

CURSOR c_ang(id_dep NUMBER) IS SELECT count(id_angajat) as numar
                               FROM angajati 
                               WHERE id_sectie = id_dep;
rec_ang c_ang%rowtype;

CURSOR c_sal(id_dep NUMBER) IS SELECT round(avg(s.suma_salariu),2)||'$' as avg_sal
                               FROM angajati a, istoric_salarii s
                               WHERE a.id_sectie = id_dep and a.id_angajat = s.id_angajat;
rec_sal c_sal%rowtype;
BEGIN
OPEN c_dep;
LOOP
FETCH c_dep INTO rec_dep;
EXIT WHEN c_dep%NOTFOUND;
DBMS_OUTPUT.PUT_LINE('<><><>  Sectia '||rec_Dep.denumire);
        OPEN c_ang(rec_dep.id_sectie);
        LOOP
        FETCH c_ang INTO rec_ang;
        EXIT WHEN c_ang%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('  <> Numarul de angajati: '||rec_ang.numar);
        END LOOP;
        CLOSE c_ang;

        OPEN c_sal(rec_dep.id_sectie);
        LOOP
        FETCH c_sal INTO rec_sal;
        EXIT WHEN c_sal%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('  <> Salariul mediu: '||rec_sal.avg_sal);
        END LOOP;
        CLOSE c_sal;
END LOOP;
CLOSE c_dep;
END;
/

EXECUTE hidden_proc;


SELECT text 
FROM ALL_SOURCE
WHERE TYPE = 'PROCEDURE' AND NAME = 'HIDDEN_PROC'
ORDER BY LINE;

BEGIN
DBMS_DDL.CREATE_WRAPPED('CREATE OR REPLACE PROCEDURE hidden_proc IS
CURSOR c_dep IS SELECT id_sectie, denumire
                FROM istoric_sectii;
rec_dep c_dep%rowtype;

CURSOR c_ang(id_dep NUMBER) IS SELECT count(id_angajat) as numar
                               FROM angajati 
                               WHERE id_sectie = id_dep;
rec_ang c_ang%rowtype;

CURSOR c_sal(id_dep NUMBER) IS SELECT round(avg(s.suma_salariu),2)||''$'' as avg_sal
                               FROM angajati a, istoric_salarii s
                               WHERE a.id_sectie = id_dep and a.id_angajat = s.id_angajat;
rec_sal c_sal%rowtype;
BEGIN
OPEN c_dep;
LOOP
FETCH c_dep INTO rec_dep;
EXIT WHEN c_dep%NOTFOUND;
DBMS_OUTPUT.PUT_LINE(''<><><>  Sectia ''||rec_Dep.denumire);
        OPEN c_ang(rec_dep.id_sectie);
        LOOP
        FETCH c_ang INTO rec_ang;
        EXIT WHEN c_ang%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(''  <> Numarul de angajati: ''||rec_ang.numar);
        END LOOP;
        CLOSE c_ang;

        OPEN c_sal(rec_dep.id_sectie);
        LOOP
        FETCH c_sal INTO rec_sal;
        EXIT WHEN c_sal%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(''  <> Salariul mediu: ''||rec_sal.avg_sal);
        END LOOP;
        CLOSE c_sal;
END LOOP;
CLOSE c_dep;
END;');
END;
/

SELECT text 
FROM ALL_SOURCE
WHERE TYPE = 'PROCEDURE' AND NAME = 'HIDDEN_PROC'
ORDER BY LINE;

EXECUTE hidden_proc;
