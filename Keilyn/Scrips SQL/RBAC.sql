--FASE 2: CONTROL DE ACCESO BASADO EN ROLES

--0. Eliminación previa para poder re-ejecutar el script sin errores
DROP ROLE IF EXISTS admin_petit, gestor_inventario, auditor_petit, empleado_operativo_1;
DROP ROLE IF EXISTS db_admin, inventory_manager, auditor, empleado_operativo;

--1. Creación de roles de grupo
CREATE ROLE db_admin NOLOGIN;
CREATE ROLE inventory_manager NOLOGIN;
CREATE ROLE auditor NOLOGIN;
CREATE ROLE empleado_operativo NOLOGIN;

--2. Denegar acceso por efecto
REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL FUNCTIONS IN SCHEMA public FROM PUBLIC;

GRANT USAGE ON SCHEMA public TO inventory_manager, auditor, empleado_operativo;
GRANT ALL ON SCHEMA public TO db_admin;

--3. Asignación de permisos
-- db_admin (Administrador general con control total sobre la estructura y gestión de usuarios).
ALTER ROLE db_admin CREATEROLE;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO db_admin;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO db_admin;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA public TO db_admin;

-- inventory_manager (Gestor de inventario con permisos de lectura, inserción y actualización sobre productos y stock). 
GRANT SELECT, INSERT, UPDATE ON producto, inventario TO inventory_manager;
GRANT SELECT ON categoria, subcategoria, proveedor, almacen, movimientoinventario TO inventory_manager;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO inventory_manager;

-- auditor (Rol con permisos estrictos de solo lectura sobre reportes y movimientos).
GRANT SELECT ON movimientoinventario, inventario TO auditor;
REVOKE INSERT, UPDATE, DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public FROM auditor;

-- empleado operativo (operaciones básicas de consulta y actualización limitada, sin acces a reportes ni administración).
GRANT SELECT ON producto, categoria, subcategoria, almacen, inventario TO empleado_operativo;
GRANT INSERT, UPDATE ON movimientoinventario TO empleado_operativo;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO empleado_operativo;
REVOKE DELETE, TRUNCATE ON ALL TABLES IN SCHEMA public FROM empleado_operativo;

--4. Creación de usuarios de prueba y asignación de roles
CREATE USER admin_petit WITH  PASSWORD 'admin_123';
GRANT db_admin TO admin_petit;

CREATE USER gestor_inventario WITH PASSWORD 'inv_123';
GRANT inventory_manager TO gestor_inventario;

CREATE USER auditor_petit WITH PASSWORD 'aud_123';
GRANT auditor TO auditor_petit;

CREATE USER empleado_operativo_1 WITH PASSWORD 'op_123';
GRANT empleado_operativo TO empleado_operativo_1;

--Prueba:
SET ROLE empleado_operativo_1;
SELECT * FROM inventario;