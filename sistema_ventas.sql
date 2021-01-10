-- phpMyAdmin SQL Dump
-- version 5.0.4
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 07-01-2021 a las 23:27:34
-- Versión del servidor: 10.4.17-MariaDB
-- Versión de PHP: 8.0.0

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `sistema_ventas`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Activar_Cliente` (`pRFC` VARCHAR(10))  begin
	declare vid_persona int;
    declare vid_cliente int;
    set vid_persona = 0;
    set vid_cliente = 0;
    if pRFC!=""
    then
		select id_persona into vid_persona from personas where RFC=pRFC limit 1;
        select id_cliente into vid_cliente from personas, clientes where personas.id_persona= clientes.id_persona
        and personas.RFC = pRFC limit 1;
        update Personas set Id_estado_eliminado = 1 where id_persona = vid_persona;
        delete from Clientes_Eliminados where id_cliente = vid_cliente limit 1;
        commit;
	else
		rollback;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Activar_Producto` (`pCodigo` VARCHAR(75))  begin
	declare vid_producto int;
    set vid_producto = 0;
    
    if pCodigo!=""
    then
		select id_producto into vid_producto from Productos where Codigo = pCodigo limit 1;
        update Productos set id_estado_eliminado = 1 where id_producto = vid_producto limit 1;
        delete from Productos_Eliminados where id_producto = vid_producto;
        commit;
	else
		rollback;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Activar_Proveedor` (IN `pRFC` VARCHAR(75))  NO SQL
begin
	declare vid_persona int;
    declare vid_proveedor int;
    set vid_persona = 0;
    set vid_proveedor = 0;
    if pRFC!=""
    then
		select id_persona into vid_persona from personas where RFC=pRFC limit 1;
        select id_proveedor into vid_proveedor from personas, proveedores where personas.id_persona= proveedores.id_persona
        and personas.RFC = pRFC limit 1;
        update Personas set Id_estado_eliminado = 1 where id_persona = vid_persona;
        delete from Proveedores_Eliminados where id_proveedor = vid_proveedor limit 1;
        commit;
	else
		rollback;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Actualizar_Campos_Cliente` (`pRFC` VARCHAR(10), `pNombre` VARCHAR(100), `pDireccion` VARCHAR(100), `pTelefono` VARCHAR(10), `pEstado` VARCHAR(50), `pMunicipio` VARCHAR(75), `pRFC_Nuevo` VARCHAR(10))  begin
	#Variables para guardar los valores del registro a modificar
	declare vid_persona int;
    declare vEstado1 int;
    declare vEstado2 int;
    declare RFC_Antiguo varchar(10);
    declare vEstado_eliminado int;
    declare vid_cliente int;
    
    set RFC_Antiguo="";
    set vid_persona=0;
    set vEstado1=0;
    set vEstado2=0;
    set vEstado_eliminado=0;
    set vid_cliente=0;
    
    #Consulta para seleccionar el id de la persona y del estado
    select id_persona into vid_persona from Personas where RFC=pRFC limit 1;
    select id_estado_eliminado into vEstado_eliminado from Personas where RFC=pRFC limit 1;
    
    #Condicion que evalua que ningun parametro este vacio
    if pRFC!="" and pNombre!="" and pDireccion!="" and pTelefono!="" and pEstado!="" and pMunicipio!="" and vEstado_eliminado=1
    then
		#Guardar valores dentro de las variables previamente declaradas
		select RFC into RFC_Antiguo from Personas where RFC=pRFC;
        select id_estado into vEstado1 from Personas where RFC=pRFC;
        select id_estado into vEstado2 from Estados_Republica where Descripcion=pEstado;
        
        #Actualizamos los campos
		update Personas set Nombre=pNombre, Direccion=pDireccion, Telefono=pTelefono, Municipio=pMunicipio
        where id_persona=vid_persona limit 1;
        
		#Condicion que evalua si el parametro de estado es distinto al que tenia previamente registrado
        #si michoacan (Id = 2) != al valor de la variable 
        #If 8!=2 entra la condicion (cuando modificamos el estado)
        #If 2!=2 no entra la condicion (cuando no modificamos el estado)
        if vEstado2!=vEstado1
		then
			select id_estado into vEstado2 from Estados where descripcion=pEstado limit 1;
			update Personas set id_estado=vEstado2 where id_persona=vid_persona limit 1;
            commit;
		else
			rollback;
		end if;
        
        #Condicion que evalua si el parametro de RFC es distinto al que tenia registrado entoces evalua que no este ya previamente registrado
        #RFC_Antiguo=11111235 (este ya lo tenia registrado)
        #RFC_Nuevo=1111325 (a este lo voy a actualizar)
        
        if pRFC_Nuevo!=RFC_Antiguo
        then
			if exists (select Personas.RFC from Personas, Clientes where Personas.id_persona=Clientes.id_persona and Personas.RFC=pRFC_Nuevo limit 1)
            then
				select "El RFC ya esta registrado" msg;
				rollback;
			else
				update Personas set RFC=pRFC_Nuevo where id_persona=vid_persona limit 1;
				commit;
            end if;
        end if;
	end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Actualizar_Campos_Empleados` (`pRFC` VARCHAR(10), `pNombre` VARCHAR(100), `pDireccion` VARCHAR(100), `pTelefono` VARCHAR(10), `pEstado` VARCHAR(50), `pMunicipio` VARCHAR(75), `pRFC_Nuevo` VARCHAR(10))  begin
	#Variables para guardar los valores del registro a modificar
	declare vid_persona int;
    declare vEstado1 int;
    declare vEstado2 int;
    declare RFC_Antiguo varchar(10);
    declare vEstado_eliminado int;
    declare vid_empleado int;
    
    set RFC_Antiguo="";
    set vid_persona=0;
    set vEstado1=0;
    set vEstado2=0;
    set vEstado_eliminado=0;
    set vid_empleado=0;
    
    #Consulta para seleccionar el id de la persona y del estado
    select id_persona into vid_persona from Personas where RFC=pRFC limit 1;
    select id_estado_eliminado into vEstado_eliminado from Personas where RFC=pRFC limit 1;
    
    #Condicion que evalua que ningun parametro este vacio
    if pRFC!="" and pNombre!="" and pDireccion!="" and pTelefono!="" and pEstado!="" and pMunicipio!="" and vEstado_eliminado=1
    then
		#Guardar valores dentro de las variables previamente declaradas
		select RFC into RFC_Antiguo from Personas where RFC=pRFC;
        select id_estado into vEstado1 from Personas where RFC=pRFC;
        select id_estado into vEstado2 from Estados_Republica where Descripcion=pEstado;
        
        #Actualizamos los campos
		update Personas set Nombre=pNombre, Direccion=pDireccion, Telefono=pTelefono, Municipio=pMunicipio
        where id_persona=vid_persona limit 1;
        
		#Condicion que evalua si el parametro de estado es distinto al que tenia previamente registrado
        #si michoacan (Id = 2) != al valor de la variable 
        #If 8!=2 entra la condicion (cuando modificamos el estado)
        #If 2!=2 no entra la condicion (cuando no modificamos el estado)
        if vEstado2!=vEstado1
		then
			select id_estado into vEstado2 from Estados where descripcion=pEstado limit 1;
			update Personas set id_estado=vEstado2 where id_persona=vid_persona limit 1;
            commit;
		else
			rollback;
		end if;
        
        #Condicion que evalua si el parametro de RFC es distinto al que tenia registrado entoces evalua que no este ya previamente registrado
        #RFC_Antiguo=11111235 (este ya lo tenia registrado)
        #RFC_Nuevo=1111325 (a este lo voy a actualizar)
        
        if pRFC_Nuevo!=RFC_Antiguo
        then
			if exists (select Personas.RFC from Personas, Empleados where Personas.id_persona=Empleados.id_persona and Personas.RFC=pRFC_Nuevo limit 1)
            then
				select "El RFC ya esta registrado" msg;
				rollback;
			else
				update Personas set RFC=pRFC_Nuevo where id_persona=vid_persona limit 1;
				commit;
            end if;
        end if;
	end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Actualizar_Campos_Proveedores` (IN `pRFC` VARCHAR(10), IN `pNombre` VARCHAR(100), IN `pDireccion` VARCHAR(100), IN `pTelefono` VARCHAR(10), IN `pEstado` VARCHAR(50), IN `pMunicipio` VARCHAR(75), IN `pEmpresa` VARCHAR(75), IN `pRFC_Nuevo` VARCHAR(10))  begin
	#Variables para guardar los valores del registro a modificar
	declare vid_persona int;
    declare vEstado1 int;
    declare vEstado2 int;
    declare RFC_Antiguo varchar(10);
    declare vEstado_eliminado int;
    declare vid_empleado int;
    declare vid_empresa int;
    
    set RFC_Antiguo="";
    set vid_persona=0;
    set vEstado1=0;
    set vEstado2=0;
    set vEstado_eliminado=0;
    set vid_empleado=0;
    set vid_empresa=0;
    
    #Consulta para seleccionar el id de la persona y del estado
    select id_persona into vid_persona from Personas where RFC=pRFC limit 1;
    select id_estado_eliminado into vEstado_eliminado from Personas where RFC=pRFC limit 1;
    select id_empresa into vid_empresa from empresa where Descripcion=pEmpresa limit 1;
    
    #Condicion que evalua que ningun parametro este vacio
    if pRFC!="" and pNombre!="" and pDireccion!="" and pTelefono!="" and pEstado!="" and pMunicipio!="" and vEstado_eliminado=1
    then
		#Guardar valores dentro de las variables previamente declaradas
		select RFC into RFC_Antiguo from Personas where RFC=pRFC;
        select id_estado into vEstado1 from Personas where RFC=pRFC;
        select id_estado into vEstado2 from Estados_Republica where Descripcion=pEstado;
        
        #Actualizamos los campos
		update Personas set Nombre=pNombre, Direccion=pDireccion, Telefono=pTelefono, Municipio=pMunicipio
        where id_persona=vid_persona limit 1;
        
        if vEstado2!=vEstado1
		then
			select id_estado into vEstado2 from Estados where descripcion=pEstado limit 1;
			update Personas set id_estado=vEstado2 where id_persona=vid_persona limit 1;
            commit;
		else
			rollback;
		end if;
        
        if pRFC_Nuevo!=RFC_Antiguo
        then
			if exists (select Personas.RFC from Personas, proveedores where Personas.id_persona=proveedores.id_persona and Personas.RFC=pRFC_Nuevo limit 1)
            then
				select "El RFC ya esta registrado" msg;
				rollback;
			else
				update Personas set RFC=pRFC_Nuevo where id_persona=vid_persona limit 1;
				commit;
            end if;
        end if;
	end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Actualizar_Nota_Cliente` (`pCliente` VARCHAR(100), `pRFC` VARCHAR(10), `pFecha` DATE, `pSubTotal` DECIMAL, `pDescuento` DECIMAL, `pIVA` DECIMAL, `pTotal` DECIMAL, `pEmpleado` VARCHAR(100), `pIdentificadorEmpleado` INT, `pId_nota_venta` INT)  begin
	declare vid_cliente int;
    declare vFecha date;
    set vid_cliente=0;
    set vFecha="";
    
    select id_cliente into vid_cliente from Personas, Clientes where RFC=pRFC and Personas.nombre=pCliente and Personas.id_persona=Clientes.id_persona limit 1;
    select Fecha into vFecha from Nota_ventas where nota_ventas.id_nota_venta=pId_nota_venta limit 1;
    
    if pCliente!="" and pRFC!="" and pEmpleado!="" and pTotal >=0 and pId_nota_venta !=0
    then
		update nota_ventas set id_empleado = pIdentificadorEmpleado, id_cliente = vid_cliente, Nombre_empleado = pEmpleado,
        SubTotal = pSubTotal, Descuento = pDescuento, IVA = pIVA, Total = pTotal where id_nota_venta=pId_nota_venta;
        commit;
	else
		select "No puede dejar un campo vacio" msg;
        rollback;
	end if;
    
    if pFecha!=vFecha
    then
		update nota_ventas set Fecha=pFecha where id_nota_venta=pId_nota_ventas;
        commit;
	else
		rollback;
	end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Actualizar_Nota_Venta` (`pId_venta` INT, `pId_nota_venta` INT, `pCodigo` VARCHAR(100), `pCantidad` INT, `pDescripcion` VARCHAR(125), `pUnidad` VARCHAR(50), `pPrecio` DECIMAL, `pDescuento` DECIMAL, `pSubTotal` DECIMAL, `pTotal` DECIMAL)  begin
	declare vid_producto int;
    declare vid_producto2 int;
    declare vcantidad int;
    declare vres int;
    declare vid_nota_venta int;
    set vid_producto2=0;
    set vid_producto=0;
    set vcantidad=0;
    set vres=0;
    set vid_nota_venta=0;
    
    if pCodigo!="" and pId_nota_venta !=0 and pCantidad > 0 and pPrecio > 0 and pTotal > 0 and pDescripcion!=""
    then
        if pId_venta != 0
        then
			select id_producto into vid_producto from Productos where Codigo=pCodigo limit 1;
			select cantidad into vcantidad from ventas,productos where Productos.codigo = pCodigo and Productos.id_producto=Ventas.id_producto and ventas.id_venta=pId_venta limit 1;
			if pCantidad > 0 and pId_venta is not null
			then
				if pCantidad = vcantidad
                then
					update ventas set id_producto=vid_producto, Cantidad=pCantidad, Descripcion=pDescripcion, Unidad = pUnidad, 
                    Precio=pPrecio, Descuento = pDescuento, SubTotal = pSubTotal, Total=pTotal where id_venta=pId_venta and id_nota_venta=pId_nota_venta limit 1;
				else
					if pCantidad > vcantidad
					then
						update ventas set id_producto=vid_producto, Cantidad=pCantidad, Descripcion=pDescripcion, Unidad = pUnidad, 
						Precio=pPrecio, Descuento = pDescuento, SubTotal = pSubTotal, Total=pTotal where id_venta=pId_venta and id_nota_venta=pId_nota_venta limit 1;
						update entradas set cantidad = cantidad-(pCantidad-vcantidad) where entradas.id_producto=vid_producto;
						commit;
					else
						if pCantidad < vcantidad
						then
							update ventas set id_producto=vid_producto, Cantidad=pCantidad, Descripcion=pDescripcion, Unidad = pUnidad, 
							Precio=pPrecio, Descuento = pDescuento, SubTotal = pSubTotal, Total=pTotal where id_venta=pId_venta and id_nota_venta=pId_nota_venta limit 1;
							update entradas set cantidad=cantidad + (vcantidad-pCantidad) where entradas.id_producto=vid_producto;
							commit;
						else
							select "Error de inserción" msg;
						end if;
					end if;
				end if;
            end if;
            else
				if pId_venta = 0
				then
					select id_producto into vid_producto2 from productos,marcas,unidad where codigo=pCodigo and productos.id_marca=Marcas.id_marca and productos.id_unidad=Unidad.id_unidad limit 1;
                    select id_nota_venta into vid_nota_venta from nota_ventas where id_nota_venta=pId_nota_venta;
                    insert into Ventas (id_nota_venta, id_producto, Cantidad, Descripcion, Unidad, Precio, Descuento, SubTotal, Total) values 
					(vid_nota_venta, vid_producto2, pCantidad, pDescripcion, pUnidad, pPrecio, pDescuento, pSubTotal, pTotal);
					update entradas set Cantidad= (Cantidad - pCantidad) where entradas.id_producto=vid_producto2;
					commit;
                else
					select "No se guardaron los cambios" msg;
                    rollback;
				end if;
        end if;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Agregar_Nota_Venta` (`pCliente` VARCHAR(100), `pRFC` VARCHAR(10), `pFecha` DATE, `pSubTotal` DECIMAL, `pDescuento` DECIMAL, `pIVA` DECIMAL, `pTotal` DECIMAL, `pEmpleado` VARCHAR(100), `pIdentificadorEmpleado` INT)  begin
		declare vid_cliente int;
		set vid_cliente=0;
		
		select id_cliente into vid_cliente from Personas, Clientes where Personas.id_persona=Clientes.id_persona and 
		Personas.nombre=pCliente and Personas.RFC=pRFC;
		
		if pCliente!="" and pFecha!="" and ptotal!=0 and pCliente!="" and pRFC!=""
		then
			insert into Nota_Ventas (id_empleado, id_cliente, Nombre_Empleado, Fecha, SubTotal, Descuento, IVA, Total, id_estado_eliminado, id_estado_venta) values 
			(pIdentificadorEmpleado, vid_cliente, pEmpleado, pFecha, pSubTotal, pDescuento, pIVA, pTotal, 1, 2);
		else
			select "No puede dejar un campo vacio" msg;
		end if;
	end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Agregar_Venta` (`pCodigo` VARCHAR(100), `pCantidad` INT, `pDescripcion` VARCHAR(125), `pUnidad` VARCHAR(50), `pPrecio` DECIMAL, `pDescuento` DECIMAL, `pSubTotal` DECIMAL, `pTotal` DECIMAL)  begin
		declare vid_producto int;
		declare vid_nota_venta int;
		set vid_nota_venta = 0;
		set vid_producto = 0;
		
		SELECT productos.`Id_producto` AS productos_Id_producto into vid_producto FROM `marcas` marcas INNER JOIN `productos` productos 
        ON marcas.`Id_marca` = productos.`Id_marca` INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
        and productos.codigo = pCodigo limit 1;
        
		select max(id_nota_venta) into vid_nota_venta from Nota_Ventas limit 1;
		
		insert into Ventas (id_nota_venta, id_producto, Cantidad, Descripcion, Unidad, Precio, Descuento, SubTotal, Total) values 
        (vid_nota_venta, vid_producto, pCantidad, pDescripcion, pUnidad, pPrecio, pDescuento, pSubTotal, pTotal);
        
		update entradas set Cantidad = (Cantidad - pCantidad) where entradas.id_producto=vid_producto;
	end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Clientes_Direccion` (`pDireccion` VARCHAR(100))  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.id_estado_eliminado=El.id_estado_eliminado 
    and P.id_estado_eliminado=1 and P.Direccion like concat('%',pDireccion,'%'); 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Clientes_Eliminados_Direccion` (`pDireccion` VARCHAR(100))  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.id_estado_eliminado=El.id_estado_eliminado 
    and P.id_estado_eliminado=2 and P.Direccion like concat('%',pDireccion,'%'); 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Clientes_Eliminados_Estado` (`pEstado` VARCHAR(50))  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.id_estado_eliminado=El.id_estado_eliminado 
    and P.id_estado_eliminado=2 and E.Descripcion like concat('%',pEstado,'%'); 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Clientes_Eliminados_Identificador` (`pIdentificador` INT)  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.id_estado_eliminado=El.id_estado_eliminado 
    and P.id_estado_eliminado=2 and C.id_cliente like concat('%',pIdentificador,'%'); 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Clientes_Eliminados_Nombre` (`pNombre` VARCHAR(100))  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.id_estado_eliminado=El.id_estado_eliminado 
    and P.id_estado_eliminado=2 and P.Nombre like concat('%',pNombre,'%'); 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Clientes_Eliminados_RFC` (`pRFC` VARCHAR(10))  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.id_estado_eliminado=El.id_estado_eliminado 
    and P.id_estado_eliminado=2 and P.RFC like concat('%',pRFC,'%'); 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Clientes_Estado` (`pEstado` VARCHAR(50))  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.id_estado_eliminado=El.id_estado_eliminado 
    and P.id_estado_eliminado=1 and E.Descripcion like concat('%',pEstado,'%'); 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Clientes_Identificador` (`pIdentificador` INT)  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.id_estado_eliminado=El.id_estado_eliminado 
    and P.id_estado_eliminado=1 and C.id_cliente like concat('%',pIdentificador,'%'); 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Clientes_Nombre` (`pNombre` VARCHAR(100))  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.id_estado_eliminado=El.id_estado_eliminado 
    and P.id_estado_eliminado=1 and P.Nombre like concat('%',pNombre,'%'); 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Clientes_RFC` (`pRFC` VARCHAR(10))  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.id_estado_eliminado=El.id_estado_eliminado 
    and P.id_estado_eliminado=1 and P.RFC like concat('%',pRFC,'%'); 
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Empleados_Direccion` (`pDireccion` VARCHAR(100))  begin
SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=1 and personas.Direccion like concat('%',pDireccion,'%') order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Empleados_Eliminados_Direccion` (`pDireccion` VARCHAR(100))  begin
	SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=2 and personas.RFC like concat('%',pDireccion,'%') order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Empleados_Eliminados_Estado` (`pEstado` VARCHAR(50))  begin
		SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=2 and personas.RFC like concat('%',pEstado,'%') order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Empleados_Eliminados_Identificador` (`pIdentificador` INT)  begin
SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=2 and empleados.id_empleado like concat('%',pIdentificador,'%') order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Empleados_Eliminados_Nombre` (IN `pNombre` VARCHAR(100))  begin
	SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=2 and personas.Nombre like concat('%',pNombre,'%') order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Empleados_Eliminados_RFC` (`pRFC` VARCHAR(10))  begin
	SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=2 and personas.RFC like concat('%',pRFC,'%') order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Empleados_Estado` (`pEstado` VARCHAR(50))  begin
SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=1 and estados_republica.Descripcion like concat('%',pEstado,'%') order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Empleados_Identificador` (`pIdentificador` INT)  begin
SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=1 and empleados.id_empleado like concat('%',pIdentificador,'%') order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Empleados_Nombre` (`pNombre` VARCHAR(100))  begin
SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=1 and personas.Nombre like concat('%',pNombre,'%') order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Empleados_RFC` (`pRFC` VARCHAR(10))  begin
SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=1 and personas.RFC like concat('%',pRFC,'%') order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Notas_Activas_No_Pagadas_Cliente` (`pNombre` VARCHAR(100))  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     and nota_ventas.id_estado_venta = 2 and personas.Nombre like concat("%",pNombre,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Notas_Activas_No_Pagadas_Empleado` (`pEmpleado` VARCHAR(100))  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     and nota_ventas.id_estado_venta = 2 and nota_ventas.Nombre_empleado like concat("%",pEmpleado,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Notas_Activas_Pagadas_Cliente` (`pNombre` VARCHAR(100))  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     and nota_ventas.id_estado_venta = 1 and personas.Nombre like concat("%",pNombre,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Notas_Activas_Pagadas_Empleado` (`pEmpleado` VARCHAR(100))  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     and nota_ventas.id_estado_venta = 1 and nota_ventas.Nombre_empleado like concat("%",pEmpleado,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Notas_Activas_Pagadas_Identificador` (`pIdentificador` INT)  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`Nombre` AS personas_Nombre,
     personas.`RFC` AS personas_RFC,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     and nota_ventas.id_estado_venta = 1 and nota_ventas.id_nota_venta like concat("%",pIdentificador,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Notas_Activas_Pagadas_Total` (`pTotal` DECIMAL)  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     and nota_ventas.id_estado_venta = 1 and nota_ventas.Total like concat("%",pTotal,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Notas_Eliminadas_No_Pagadas_Cliente` (`pNombre` VARCHAR(100))  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 2
     and personas.Nombre like concat("%",pNombre,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Notas_Eliminadas_No_Pagadas_Empleado` (`pEmpleado` VARCHAR(100))  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 2
     and nota_ventas.Nombre_empleado like concat("%",pEmpleado,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Notas_Eliminadas_No_Pagadas_Identificador` (`pIdentificador` INT)  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 2
     and nota_ventas.id_nota_venta like concat("%",pIdentificador,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Notas_No_Activas_Pagadas_Total` (`pTotal` DECIMAL)  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     and nota_ventas.id_estado_venta = 2 and nota_ventas.Total like concat("%",pTotal,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Notas_No_Eliminadas_Pagadas_Total` (`pTotal` DECIMAL)  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 2
     and nota_ventas.Total like concat("%",pTotal,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Activos_Clasificacion` (`pClasificacion` VARCHAR(125))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 1 and productos.Clasificacion like concat("%",pClasificacion,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Activos_Codigo` (`pCodigo` VARCHAR(75))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 1 and productos.Codigo like concat("%",pCodigo,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Activos_Descripcion` (`pDescripcion` VARCHAR(125))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 1 and productos.Descripcion like concat("%",pDescripcion,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Activos_Identificador` (`pIdentificador` INT)  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 1 and productos.Id_producto like concat("%",pIdentificador,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Activos_Lote` (`pLote` VARCHAR(75))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 1 and productos.Lote like concat("%",pLote,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Activos_Marca` (`pMarca` VARCHAR(75))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 1 and marcas.Descripcion like concat("%",pMarca,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Activos_Unidad` (`pUnidad` VARCHAR(30))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 1 and unidad.Descripcion like concat("%",pUnidad,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Eliminados_Clasificacion` (`pClasificacion` VARCHAR(125))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 2 and productos.Clasificacion like concat("%",pClasificacion,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Eliminados_Codigo` (`pCodigo` VARCHAR(75))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 2 and productos.Codigo like concat("%",pCodigo,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Eliminados_Descripcion` (`pDescripcion` VARCHAR(125))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 2 and productos.Descripcion like concat("%",pDescripcion,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Eliminados_Identificador` (`pIdentificador` INT)  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 2 and productos.Id_producto like concat("%",pIdentificador,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Eliminados_Lote` (`pLote` VARCHAR(75))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 2 and productos.Lote like concat("%",pLote,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Eliminados_Marca` (`pMarca` VARCHAR(75))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 2 and marcas.Descripcion like concat("%",pMarca,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Productos_Eliminados_Unidad` (`pUnidad` VARCHAR(30))  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 2 and unidad.Descripcion like concat("%",pUnidad,"%");
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Proveedores_Direccion` (IN `pDireccion` VARCHAR(100))  begin
	SELECT
     proveedores.`Id_proveedor` AS proveedores_Id_proveedor,
     personas.`RFC` AS proveedores_RFC,
     personas.`Nombre` AS proveedores_Nombre,
     personas.`Direccion` AS proveedores_Direccion,
     personas.`Telefono` AS proveedores_Telefono,
     empresa.`Descripcion` AS proveedores_Descripcion,
     estados_republica.`Descripcion` AS estado_Descripcion,
     personas.`Municipio` AS proveedores_Municipio
FROM `proveedores` proveedores INNER JOIN `personas` personas ON proveedores.`Id_persona` = personas.`id_persona` INNER JOIN `estados_republica` estados_republica ON personas.`id_estado` = estados_republica.`id_estado` INNER JOIN `estado_eliminado` estado_eliminado ON personas.`id_estado_eliminado` = estado_eliminado.`id_estado_eliminado` INNER JOIN `empresa` empresa ON proveedores.`id_empresa` = empresa.`id_empresa` AND personas.id_estado_eliminado = 1  and personas.Direccion like concat('%',pDireccion,'%') order by proveedores.Id_proveedor;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Proveedores_Eliminados_Direccion` (IN `pDireccion` VARCHAR(100))  begin
	SELECT
     proveedores.`Id_proveedor` AS proveedores_Id_proveedor,
     personas.`RFC` AS proveedores_RFC,
     personas.`Nombre` AS proveedores_Nombre,
     personas.`Direccion` AS proveedores_Direccion,
     personas.`Telefono` AS proveedores_Telefono,
     empresa.`Descripcion` AS proveedores_Descripcion,
     estados_republica.`Descripcion` AS estado_Descripcion,
     personas.`Municipio` AS proveedores_Municipio
FROM `proveedores` proveedores INNER JOIN `personas` personas ON proveedores.`Id_persona` = personas.`id_persona` INNER JOIN `estados_republica` estados_republica ON personas.`id_estado` = estados_republica.`id_estado` INNER JOIN `estado_eliminado` estado_eliminado ON personas.`id_estado_eliminado` = estado_eliminado.`id_estado_eliminado` INNER JOIN `empresa` empresa ON proveedores.`id_empresa` = empresa.`id_empresa` AND personas.id_estado_eliminado = 2  and personas.Direccion like concat('%',pDireccion,'%') order by proveedores.Id_proveedor;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Proveedores_Eliminados_Estado` (IN `pEstado` VARCHAR(50))  begin
	SELECT
     proveedores.`Id_proveedor` AS proveedores_Id_proveedor,
     personas.`RFC` AS proveedores_RFC,
     personas.`Nombre` AS proveedores_Nombre,
     personas.`Direccion` AS proveedores_Direccion,
     personas.`Telefono` AS proveedores_Telefono,
     empresa.`Descripcion` AS proveedores_Descripcion,
     estados_republica.`Descripcion` AS estado_Descripcion,
     personas.`Municipio` AS proveedores_Municipio
FROM `proveedores` proveedores INNER JOIN `personas` personas ON proveedores.`Id_persona` = personas.`id_persona` INNER JOIN `estados_republica` estados_republica ON personas.`id_estado` = estados_republica.`id_estado` INNER JOIN `estado_eliminado` estado_eliminado ON personas.`id_estado_eliminado` = estado_eliminado.`id_estado_eliminado` INNER JOIN `empresa` empresa ON proveedores.`id_empresa` = empresa.`id_empresa` AND personas.id_estado_eliminado = 2  and estados_republica.Descripcion like concat('%',pEstado,'%') order by proveedores.Id_proveedor;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Proveedores_Eliminados_Nombre` (IN `pNombre` VARCHAR(100))  begin
	SELECT
     proveedores.`Id_proveedor` AS proveedores_Id_proveedor,
     personas.`RFC` AS proveedores_RFC,
     personas.`Nombre` AS proveedores_Nombre,
     personas.`Direccion` AS proveedores_Direccion,
     personas.`Telefono` AS proveedores_Telefono,
     empresa.`Descripcion` AS proveedores_Descripcion,
     estados_republica.`Descripcion` AS estado_Descripcion,
     personas.`Municipio` AS proveedores_Municipio
FROM `proveedores` proveedores INNER JOIN `personas` personas ON proveedores.`Id_persona` = personas.`id_persona` INNER JOIN `estados_republica` estados_republica ON personas.`id_estado` = estados_republica.`id_estado` INNER JOIN `estado_eliminado` estado_eliminado ON personas.`id_estado_eliminado` = estado_eliminado.`id_estado_eliminado` INNER JOIN `empresa` empresa ON proveedores.`id_empresa` = empresa.`id_empresa` AND personas.id_estado_eliminado = 2  and personas.Nombre like concat('%',pNombre,'%') order by proveedores.Id_proveedor;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Proveedores_Estado` (IN `pEstado` VARCHAR(50))  begin
	SELECT
     proveedores.`Id_proveedor` AS proveedores_Id_proveedor,
     personas.`RFC` AS proveedores_RFC,
     personas.`Nombre` AS proveedores_Nombre,
     personas.`Direccion` AS proveedores_Direccion,
     personas.`Telefono` AS proveedores_Telefono,
     empresa.`Descripcion` AS proveedores_Descripcion,
     estados_republica.`Descripcion` AS estado_Descripcion,
     personas.`Municipio` AS proveedores_Municipio
FROM `proveedores` proveedores INNER JOIN `personas` personas ON proveedores.`Id_persona` = personas.`id_persona` INNER JOIN `estados_republica` estados_republica ON personas.`id_estado` = estados_republica.`id_estado` INNER JOIN `estado_eliminado` estado_eliminado ON personas.`id_estado_eliminado` = estado_eliminado.`id_estado_eliminado` INNER JOIN `empresa` empresa ON proveedores.`id_empresa` = empresa.`id_empresa` AND personas.id_estado_eliminado = 1  and estados_republica.Descripcion like concat('%',pEstado,'%') order by proveedores.Id_proveedor;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Proveedores_Nombre` (IN `pNombre` VARCHAR(100))  begin
	SELECT
     proveedores.`Id_proveedor` AS proveedores_Id_proveedor,
     personas.`RFC` AS proveedores_RFC,
     personas.`Nombre` AS proveedores_Nombre,
     personas.`Direccion` AS proveedores_Direccion,
     personas.`Telefono` AS proveedores_Telefono,
     empresa.`Descripcion` AS proveedores_Descripcion,
     estados_republica.`Descripcion` AS estado_Descripcion,
     personas.`Municipio` AS proveedores_Municipio
FROM `proveedores` proveedores INNER JOIN `personas` personas ON proveedores.`Id_persona` = personas.`id_persona` INNER JOIN `estados_republica` estados_republica ON personas.`id_estado` = estados_republica.`id_estado` INNER JOIN `estado_eliminado` estado_eliminado ON personas.`id_estado_eliminado` = estado_eliminado.`id_estado_eliminado` INNER JOIN `empresa` empresa ON proveedores.`id_empresa` = empresa.`id_empresa` AND personas.id_estado_eliminado = 1 and personas.Nombre like concat('%',pNombre,'%') order by proveedores.Id_proveedor;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Buscar_Proveedor_Identificador` (IN `pIdentificador` INT)  begin
	SELECT
     proveedores.`Id_proveedor` AS proveedores_Id_proveedor,
     personas.`RFC` AS proveedores_RFC,
     personas.`Nombre` AS proveedores_Nombre,
     personas.`Direccion` AS proveedores_Direccion,
     personas.`Telefono` AS proveedores_Telefono,
     empresa.`Descripcion` AS proveedores_Descripcion,
     estados_republica.`Descripcion` AS estado_Descripcion,
     personas.`Municipio` AS proveedores_Municipio
FROM `proveedores` proveedores INNER JOIN `personas` personas ON proveedores.`Id_persona` = personas.`id_persona` INNER JOIN `estados_republica` estados_republica ON personas.`id_estado` = estados_republica.`id_estado` INNER JOIN `estado_eliminado` estado_eliminado ON personas.`id_estado_eliminado` = estado_eliminado.`id_estado_eliminado` INNER JOIN `empresa` empresa ON proveedores.`id_empresa` = empresa.`id_empresa` AND personas.id_estado_eliminado = 1  and proveedores.Id_proveedor like concat('%',pIdentificador,'%') order by proveedores.Id_proveedor;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Eliminar_Cliente` (`pRFC` VARCHAR(10))  begin
	declare vid_cliente int;
    set vid_cliente = 0;
    
    if pRFC!=""
    then
		#Selecciona el id del cliente con base en el RFC
		select Clientes.id_cliente into vid_cliente from Personas, Clientes where Personas.id_persona=Clientes.id_persona
        and Personas.RFC=pRFC limit 1;
        
		#Ingresamos el cliente en la lista de clientes eliminados
		insert into Clientes_Eliminados (id_cliente, fecha_eliminacion) values (vid_cliente, current_date());
		commit;
	end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Eliminar_Empleado` (`pRFC` VARCHAR(10))  begin
	declare vid_empleado int;
    set vid_empleado = 0;
    
    if pRFC!=""
    then
		#Selecciona el id del cliente con base en el RFC
		select Empleado.id_empleado into vid_empleado from Personas, Empleados where Personas.id_persona=Clientes.id_empleado
        and Personas.RFC=pRFC limit 1;
        
		#Ingresamos el cliente en la lista de clientes eliminados
		insert into Empleados_Eliminados (id_empleado, fecha_eliminacion) values (vid_empleado, current_date());
		commit;
	end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Eliminar_Fila` (`pId_Venta` INT, `pSubTotal` DECIMAL, `pDescuento` DECIMAL, `pIVA` DECIMAL, `pTotal` DECIMAL, `pId_nota_venta` INT)  begin
	delete from ventas where id_venta=pId_Venta limit 1;
    update Nota_ventas set SubTotal = pSubTotal, Descuento = pDescuento, IVA = pIVA, Total = pTotal where id_nota_venta=pId_nota_venta;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Eliminar_Nota_Venta` (`pId_nota_venta` INT)  begin
	insert into ventas_eliminadas (id_nota_venta, Fecha_eliminacion) values (pId_nota_venta, current_date());
    update Nota_ventas set id_estado_eliminado = 2 where id_nota_venta = pId_nota_venta limit 1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Eliminar_Producto` (`pCodigo` VARCHAR(100))  begin
	declare vid_producto int;
    set vid_producto=0;
    
    if pCodigo!=""
    then
		select id_producto into vid_producto from productos where Codigo=pCodigo limit 1;
		insert into Productos_Eliminados (Id_producto, fecha_eliminacion) values (vid_producto, current_date());
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Eliminar_proveedor` (IN `pRFC` VARCHAR(10))  begin
	declare vid_proveedor int;
    set vid_proveedor = 0;
    
    if pRFC!=""
    then
		#Selecciona el id del proveedor con base en el RFC
		select proveedores.id_proveedor into vid_proveedor from Personas, Proveedores where Personas.id_persona=Proveedores.id_persona
        and Personas.RFC=pRFC limit 1;
        
		#Ingresamos el proveedor en la lista de proveedores eliminados
		insert into Proveedores_Eliminados (id_proveedor) values (vid_proveedor);
		commit;
	end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Ingresar_Clientes` (`pRFC` VARCHAR(10), `pNombre` VARCHAR(100), `pDireccion` VARCHAR(125), `pTelefono` VARCHAR(10), `pEstado` VARCHAR(50), `pMunicipio` VARCHAR(75))  begin
	declare vid_estado int;
    declare vRFC varchar(10);
    set vid_estado=0;
    set vRFC="";
    
    select id_estado into vid_estado from Estados_Republica where Descripcion=pEstado limit 1;
    select RFC into vRFC from Personas where RFC=pRFC limit 1;
	if pRFC!="" and pNombre!="" and pDireccion!="" and pTelefono!="" and pEstado!="" and pMunicipio!=""
    then
		if pRFC!=vRFC
			then
				insert into Personas (RFC, Nombre, Direccion, Telefono, id_estado, Municipio, Id_estado_eliminado) values
				(pRFC, pNombre, pDireccion, pTelefono, vid_estado, pMunicipio, 1);
				insert into Clientes (id_persona) values (last_insert_id());
				commit;
			else
                select "El RFC ya esta registrado" msg;
				rollback;
			end if;
		else
			select 'No puede dejar un campo vacio' msg;
			rollback;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Ingresar_Empleado` (`pImagen` VARCHAR(255), `pRFC` VARCHAR(10), `pNombre` VARCHAR(100), `pDireccion` VARCHAR(125), `pTelefono` VARCHAR(10), `pEstado` VARCHAR(50), `pMunicipio` VARCHAR(75))  begin
	declare vid_estado int;
    declare vRFC varchar(10);
    set vid_estado=0;
    set vRFC="";
    
    select id_estado into vid_estado from Estados_Republica where Descripcion=pEstado limit 1;
    select RFC into vRFC from Personas where RFC=pRFC limit 1;
	if pRFC!="" and pNombre!="" and pDireccion!="" and pTelefono!="" and pEstado!="" and pMunicipio!=""
    then
		if pRFC!=vRFC
			then
				insert into Personas (RFC, Nombre, Direccion, Telefono, id_estado, Municipio, Id_estado_eliminado) values
				(pRFC, pNombre, pDireccion, pTelefono, vid_estado, pMunicipio, 1);
				insert into Empleados (id_persona,Imagen_empleado) values (last_insert_id(),"");
				commit;
			else
                select "El RFC ya esta registrado" msg;
				rollback;
			end if;
		else
			select 'No puede dejar un campo vacio' msg;
			rollback;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Ingresar_Empleados` (IN `pRFC` VARCHAR(10), IN `pNombre` VARCHAR(100), IN `pDireccion` VARCHAR(125), IN `pTelefono` VARCHAR(10), IN `pEstado` VARCHAR(50), IN `pMunicipio` VARCHAR(75))  begin
	declare vid_estado int;
    declare vRFC varchar(10);
    set vid_estado=0;
    set vRFC="";
    
    select id_estado into vid_estado from Estados_Republica where Descripcion=pEstado limit 1;
    select RFC into vRFC from Personas where RFC=pRFC limit 1;
	if pRFC!="" and pNombre!="" and pDireccion!="" and pTelefono!="" and pEstado!="" and pMunicipio!=""
    then
		if pRFC!=vRFC
			then
				insert into Personas (RFC, Nombre, Direccion, Telefono, id_estado, Municipio, Id_estado_eliminado) values
				(pRFC, pNombre, pDireccion, pTelefono, vid_estado, pMunicipio, 1);
				insert into Empleados (id_persona, Imagen_empleado) values (last_insert_id(), "");
				commit;
			else
                select "El RFC ya esta registrado" msg;
				rollback;
			end if;
		else
			select 'No puede dejar un campo vacio' msg;
			rollback;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Ingresar_Productos` (`pCodigo` VARCHAR(75), `pDescripcion` VARCHAR(125), `pUnidad` VARCHAR(20), `pMarca` VARCHAR(50), `pClasificacion` VARCHAR(125), `pCosto` DECIMAL, `pLote` VARCHAR(75), `pPrecioVenta` DECIMAL, `pPrecioUno` DECIMAL, `pPrecioDos` DECIMAL, `pPrecioTres` DECIMAL, `pPrecioCuatro` DECIMAL, `pStock` INT, `pAlmacen` VARCHAR(25))  begin
	declare vid_marca int;
    declare vid_unidad int;
    declare vid_almacen int;
    declare vCodigo varchar(50);
    set vCodigo="";
    set vid_marca=0;
    set vid_unidad=0;
    set vid_almacen=0;
    
    select codigo into vCodigo from Productos where codigo=pCodigo limit 1;
    select id_unidad into vid_unidad from Unidad where Descripcion=pUnidad limit 1;
    select id_almacen into vid_almacen from Almacenes where Descripcion=pAlmacen limit 1;
    select id_marca into vid_marca from Marcas where Descripcion=pMarca limit 1;
    if vid_marca=0
    then
		insert into marcas (Descripcion) values (pMarca);
    end if;
    select id_marca into vid_marca from Marcas where Descripcion=pMarca;
    
    if pCodigo!="" and pDescripcion!="" and pUnidad!="" and pMarca!="" and pClasificacion!="" and pCosto>0 and pPrecioVenta>=0 and pPreciouno>=0 and pPrecioDos>=0
    and pPrecioTres>=0 and pPrecioCuatro>=0 and pStock>0
    then
		if pCodigo!=vCodigo
        then
			insert into Productos (Codigo, Descripcion, id_unidad, id_marca, Clasificacion, Costo, Lote, Precio_venta, Precio_uno, 
            Precio_dos, Precio_tres, Precio_cuatro, Imagen, id_estado_eliminado, fecha_actualizacion) values (pCodigo, pDescripcion, vid_unidad, vid_marca, 
            pClasificacion, pCosto, pLote, pPrecioVenta, pPrecioUno, pPrecioDos, pPrecioTres, pPrecioCuatro, "", 1, now());
            insert into Entradas (id_producto,id_almacen,cantidad) values (last_insert_id(),vid_almacen,pStock);
            commit;
            else
				select "El codigo ya esta registrado" msg;
                rollback;
		end if;
	else
		select "No puede dejar un campo vacio" msg;
		rollback;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Ingresar_Proveedores` (IN `pRFC` VARCHAR(10), IN `pNombre` VARCHAR(100), IN `pDireccion` VARCHAR(125), IN `pTelefono` VARCHAR(10), IN `pEstado` VARCHAR(50), IN `pMunicipio` VARCHAR(75), IN `pEmpresa` VARCHAR(70))  begin
	declare vid_estado int;
    declare vid_empresa int;
    declare vRFC varchar(10);
    set vid_estado=0;
    set vid_empresa=0;
    set vRFC="";
    
    select estados_republica.id_estado into vid_estado from Estados_Republica where estados_republica.Descripcion=pEstado limit 1;
    
    select empresa.Id_empresa into vid_empresa from empresa where empresa.Descripcion=pEmpresa limit 1;
    
    select RFC into vRFC from Personas where RFC=pRFC limit 1;
    
	if pRFC!="" and pNombre!="" and pDireccion!="" and pTelefono!="" and pEstado!="" and pMunicipio!=""
    then
		if pRFC!=vRFC
			then
				insert into Personas (RFC, Nombre, Direccion, Telefono, id_estado, Municipio, Id_estado_eliminado) values
				(pRFC, pNombre, pDireccion, pTelefono, vid_estado, pMunicipio, 1);
				insert into proveedores (id_persona,id_empresa) values (last_insert_id(),vid_empresa);
				commit;
			else
                select "El RFC ya esta registrado" msg;
				rollback;
			end if;
		else
			select 'No puede dejar un campo vacio' msg;
			rollback;
    end if;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Lista_Productos_Activos` ()  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Lista_Productos_Eliminados` ()  begin
	SELECT
		 productos.`Id_producto` AS productos_Id_producto,
		 productos.`Codigo` AS productos_Codigo,
		 productos.`Descripcion` AS productos_Descripcion,
		 productos.`Clasificacion` AS productos_Clasificacion,
		 marcas.`Descripcion` AS marcas_Descripcion,
		 unidad.`Descripcion` AS unidad_Descripcion,
		 entradas.`Cantidad` AS entradas_Cantidad,
		 productos.`Lote` AS productos_Lote,
		 productos.`Costo` AS productos_Costo,
		 productos.`Precio_venta` AS productos_Precio_venta,
		 productos.`Precio_uno` AS productos_Precio_uno,
		 productos.`Precio_dos` AS productos_Precio_dos,
		 productos.`Precio_tres` AS productos_Precio_tres,
		 productos.`Precio_cuatro` AS productos_Precio_cuatro,
         almacenes.`Descripcion` as almacenes_Descripcion,
		 productos.`fecha_actualizacion` AS productos_fecha_actualizacion
	FROM
		 `productos` productos INNER JOIN `unidad` unidad ON productos.`Id_unidad` = unidad.`Id_unidad`
		 INNER JOIN `entradas` entradas ON productos.`Id_producto` = entradas.`Id_producto`
		 INNER JOIN `marcas` marcas ON productos.`Id_marca` = marcas.`Id_marca`
		 INNER JOIN `almacenes` almacenes ON entradas.`Id_almacen` = almacenes.`Id_almacen`
		 AND productos.id_estado_eliminado = 2;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Llenar_Lista_Productos` (`pId` INT)  begin
	SELECT
		 productos.`Codigo` AS productos_Codigo,
		 ventas.`Cantidad` AS ventas_Cantidad,
		 ventas.`Descripcion` AS ventas_Descripcion,
		 ventas.`Unidad` AS ventas_Unidad,
		 ventas.`Precio` AS ventas_Precio,
		 ventas.`Descuento` AS ventas_Descuento,
		 ventas.`SubTotal` AS ventas_SubTotal,
		 ventas.`Total` AS ventas_Total,
		 ventas.`Id_venta` AS ventas_Id_venta
	FROM
		 `productos` productos INNER JOIN `ventas` ventas ON productos.`Id_producto` = ventas.`Id_producto`
		 INNER JOIN `nota_ventas` nota_ventas ON ventas.`Id_nota_venta` = nota_ventas.`Id_nota_venta`
		 and nota_ventas.id_nota_venta = pId order by ventas.id_venta;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Almacenes` ()  begin
		select descripcion from Almacenes;
    end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Anterior_Nota` (`pId_nota_venta` INT)  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Id_empleado` AS nota_ventas_Id_empleado,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`Total` AS nota_ventas_Total,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     and nota_ventas.id_nota_venta < pId_nota_venta order by nota_ventas_Id_nota_venta desc limit 0,1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Clientes_Activos` ()  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.Id_estado_eliminado=El.Id_estado_eliminado 
    and P.id_estado_eliminado=1 order by C.id_cliente;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Clientes_Eliminados` ()  begin
	select C.id_cliente, P.RFC, P.Nombre, P.Direccion, P.Telefono, E.Descripcion,
	P.Municipio from Personas P, Clientes C,Estados_Republica E, Estado_Eliminado El 
    where P.id_persona=C.id_persona and P.id_estado=E.id_estado and P.id_estado_eliminado=El.id_estado_eliminado 
    and P.id_estado_eliminado=2 order by C.id_cliente;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Direccion_Identificador_Empleado` (`pId_nota_venta` INT)  begin
	SELECT
		 (SELECT
		 personas.`Direccion` AS personas_Direccion
	FROM
		 `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
		 INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_nota_venta = pId_nota_venta) AS Cliente_Direccion,
		 nota_ventas.`Id_empleado` AS nota_ventas_Id_empleado
	FROM
		 `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
		 INNER JOIN `nota_ventas` nota_ventas ON empleados.`Id_empleado` = nota_ventas.`Id_empleado` and nota_ventas.id_nota_venta = pId_nota_venta;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Empleados_Activos` ()  begin
SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=1 order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Empleados_Eliminados` ()  NO SQL
begin
SELECT
     empleados.`Id_empleado` AS empleados_Id_empleado,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion,
     personas.`Telefono` AS personas_Telefono,
     estados_republica.`Descripcion` AS estados_republica_Descripcion,
     personas.`Municipio` AS personas_Municipio
FROM
     `personas` personas INNER JOIN `empleados` empleados ON personas.`Id_persona` = empleados.`Id_persona`
     INNER JOIN `estados_republica` estados_republica ON personas.`Id_estado` = estados_republica.`Id_estado`
     and personas.id_estado_eliminado=2 order by empleados.id_empleado;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Empresas` ()  begin
	select descripcion from empresa;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Estados` ()  begin
	select descripcion from Estados_Republica;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Notas_Activas_No_Pagadas` ()  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     and nota_ventas.id_estado_venta = 2;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Notas_Activas_Pagadas` ()  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     and nota_ventas.id_estado_venta = 1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Notas_Eliminadas` ()  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     nota_ventas.`Total` AS nota_ventas_Total
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 2;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Primer_Nota` ()  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Id_empleado` AS nota_ventas_Id_empleado,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`Total` AS nota_ventas_Total,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
	 order by nota_ventas_Id_nota_venta desc limit 0,1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Proveedores_Activos` ()  begin
SELECT proveedores.`id_proveedor` AS proveedores_Id_proveedor, personas.`RFC` AS proveedores_RFC, personas.`Nombre` AS proveedores_Nombre, personas.`Direccion` AS proveedores_Direccion, empresa.`Descripcion` AS proveedores_Descripcion, personas.`Telefono` AS proveedores_Telefono, estados_republica.`Descripcion` AS estado_Descripcion, personas.`Municipio` AS proveedores_Municipio, estado_eliminado.`id_estado_eliminado` AS estado_eliminado_id FROM `proveedores` proveedores INNER JOIN `personas` personas ON proveedores.`Id_persona` = personas.`id_persona` INNER JOIN `estados_republica` estados_republica ON personas.`id_estado` = estados_republica.`id_estado` INNER JOIN `estado_eliminado` estado_eliminado ON personas.`id_estado_eliminado` = estado_eliminado.`id_estado_eliminado` INNER JOIN `empresa` empresa ON proveedores.`id_empresa` = empresa.`id_empresa` AND personas.id_estado_eliminado = 1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Proveedores_Eliminados` ()  begin
SELECT proveedores.`id_proveedor` AS proveedores_Id_proveedor, personas.`RFC` AS proveedores_RFC, personas.`Nombre` AS proveedores_Nombre, personas.`Direccion` AS proveedores_Direccion, empresa.`Descripcion` AS proveedores_Descripcion, personas.`Telefono` AS proveedores_Telefono, estados_republica.`Descripcion` AS estado_Descripcion, personas.`Municipio` AS proveedores_Municipio, estado_eliminado.`id_estado_eliminado` AS estado_eliminado_id FROM `proveedores` proveedores INNER JOIN `personas` personas ON proveedores.`Id_persona` = personas.`id_persona` INNER JOIN `estados_republica` estados_republica ON personas.`id_estado` = estados_republica.`id_estado` INNER JOIN `estado_eliminado` estado_eliminado ON personas.`id_estado_eliminado` = estado_eliminado.`id_estado_eliminado` INNER JOIN `empresa` empresa ON proveedores.`id_empresa` = empresa.`id_empresa` AND personas.id_estado_eliminado = 2;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Siguiente_Nota` (`pId_nota_venta` INT)  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Id_empleado` AS nota_ventas_Id_empleado,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`Total` AS nota_ventas_Total,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     and nota_ventas.id_nota_venta > pId_nota_venta order by nota_ventas_Id_nota_venta asc limit 0,1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Stock` (`pCodigo` VARCHAR(100))  begin
		select cantidad from entradas,productos,almacenes where productos.id_producto=entradas.id_producto and 
		almacenes.id_almacen=entradas.id_almacen and productos.codigo=pcodigo limit 1;
	end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Ultima_Nota` (`pId_nota_venta` INT)  begin
	SELECT
     nota_ventas.`Id_nota_venta` AS nota_ventas_Id_nota_venta,
     nota_ventas.`Id_empleado` AS nota_ventas_Id_empleado,
     nota_ventas.`Nombre_empleado` AS nota_ventas_Nombre_empleado,
     nota_ventas.`Fecha` AS nota_ventas_Fecha,
     nota_ventas.`SubTotal` AS nota_ventas_SubTotal,
     nota_ventas.`Descuento` AS nota_ventas_Descuento,
     nota_ventas.`Total` AS nota_ventas_Total,
     nota_ventas.`IVA` AS nota_ventas_IVA,
     personas.`RFC` AS personas_RFC,
     personas.`Nombre` AS personas_Nombre,
     personas.`Direccion` AS personas_Direccion
	FROM
     `personas` personas INNER JOIN `clientes` clientes ON personas.`Id_persona` = clientes.`Id_persona`
     INNER JOIN `nota_ventas` nota_ventas ON clientes.`Id_cliente` = nota_ventas.`Id_cliente` and nota_ventas.id_estado_eliminado = 1
     order by nota_ventas_Id_nota_venta limit 0,1;
end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Mostrar_Unidades` ()  begin
		select descripcion from Unidad;
    end$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Pagar_Nota` (`pid_nota_venta` INT)  begin
		update nota_ventas set id_estado_venta = 1 where id_nota_venta = pid_nota_venta limit 1;
    end$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `almacenes`
--

CREATE TABLE `almacenes` (
  `Id_almacen` int(11) NOT NULL,
  `Descripcion` varchar(75) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `almacenes`
--

INSERT INTO `almacenes` (`Id_almacen`, `Descripcion`) VALUES
(1, 'ALMACEN 1');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `Id_cliente` int(11) NOT NULL,
  `Id_persona` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`Id_cliente`, `Id_persona`) VALUES
(1, 1),
(2, 2);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes_eliminados`
--

CREATE TABLE `clientes_eliminados` (
  `Id_cliente_eliminado` int(11) NOT NULL,
  `Id_cliente` int(11) NOT NULL,
  `Fecha_eliminacion` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Disparadores `clientes_eliminados`
--
DELIMITER $$
CREATE TRIGGER `Actualizar_Estado_Eliminado_Cliente` AFTER INSERT ON `clientes_eliminados` FOR EACH ROW begin
	declare vid_persona int;
    set vid_persona = 0;
    
	select Personas.id_persona into vid_persona from Personas, Clientes, Clientes_Eliminados where Personas.id_persona=Clientes.id_persona
	and Clientes.id_cliente = Clientes_Eliminados.id_cliente and Clientes_Eliminados.id_cliente = new.id_cliente;
	update personas set id_estado_eliminado = 2 where id_persona = vid_persona;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `Id_empleado` int(11) NOT NULL,
  `Id_persona` int(11) NOT NULL,
  `Imagen_empleado` varchar(400) COLLATE utf8_spanish_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`Id_empleado`, `Id_persona`, `Imagen_empleado`) VALUES
(1, 3, ''),
(2, 4, ''),
(3, 5, '');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados_eliminados`
--

CREATE TABLE `empleados_eliminados` (
  `Id_empleado_eliminado` int(11) NOT NULL,
  `Id_empleado` int(11) NOT NULL,
  `Fecha_eliminacion` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Disparadores `empleados_eliminados`
--
DELIMITER $$
CREATE TRIGGER `Actualizar_Estado_Eliminado_Empleado` AFTER INSERT ON `empleados_eliminados` FOR EACH ROW begin
	declare vid_persona int;
    set vid_persona = 0;
    
	select Personas.id_persona into vid_persona from Personas, Empleados, Empleados_Eliminados where Personas.id_persona=Empleados.id_persona
	and Empleados.id_empleado = Empleados_Eliminados.id_empleado and Empleados_Eliminados.id_empleado = new.id_empleado;
	update personas set id_estado_eliminado = 2 where id_persona = vid_persona;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empresa`
--

CREATE TABLE `empresa` (
  `Id_empresa` int(11) NOT NULL,
  `Descripcion` varchar(75) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `empresa`
--

INSERT INTO `empresa` (`Id_empresa`, `Descripcion`) VALUES
(1, 'Sabritas'),
(2, 'Pepsi Company'),
(3, 'Coca Cola S.A. de C.V.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `entradas`
--

CREATE TABLE `entradas` (
  `Id_entrada` int(11) NOT NULL,
  `Id_producto` int(11) NOT NULL,
  `Id_almacen` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `entradas`
--

INSERT INTO `entradas` (`Id_entrada`, `Id_producto`, `Id_almacen`, `Cantidad`) VALUES
(1, 1, 1, 66),
(2, 2, 1, 71);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estados_republica`
--

CREATE TABLE `estados_republica` (
  `Id_estado` int(11) NOT NULL,
  `Descripcion` varchar(75) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `estados_republica`
--

INSERT INTO `estados_republica` (`Id_estado`, `Descripcion`) VALUES
(1, 'EDO. MEX');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_eliminado`
--

CREATE TABLE `estado_eliminado` (
  `Id_estado_eliminado` int(11) NOT NULL,
  `Descripcion` varchar(20) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `estado_eliminado`
--

INSERT INTO `estado_eliminado` (`Id_estado_eliminado`, `Descripcion`) VALUES
(1, 'Activo'),
(2, 'Eliminado');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `estado_nota_venta`
--

CREATE TABLE `estado_nota_venta` (
  `Id_estado_venta` int(11) NOT NULL,
  `Descripcion` varchar(75) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `estado_nota_venta`
--

INSERT INTO `estado_nota_venta` (`Id_estado_venta`, `Descripcion`) VALUES
(1, 'PAGADA'),
(2, 'PENDIENTE PAGO');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `marcas`
--

CREATE TABLE `marcas` (
  `Id_marca` int(11) NOT NULL,
  `Descripcion` varchar(75) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `marcas`
--

INSERT INTO `marcas` (`Id_marca`, `Descripcion`) VALUES
(2, 'MARINELA'),
(1, 'SABRITAS');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `nota_ventas`
--

CREATE TABLE `nota_ventas` (
  `Id_nota_venta` int(11) NOT NULL,
  `Id_empleado` int(11) NOT NULL,
  `Id_cliente` int(11) NOT NULL,
  `Nombre_empleado` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `Fecha` date NOT NULL,
  `SubTotal` decimal(10,0) NOT NULL,
  `Descuento` decimal(10,0) NOT NULL,
  `IVA` decimal(10,0) NOT NULL,
  `Total` decimal(10,0) NOT NULL,
  `Id_estado_eliminado` int(11) NOT NULL,
  `Id_estado_venta` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `nota_ventas`
--

INSERT INTO `nota_ventas` (`Id_nota_venta`, `Id_empleado`, `Id_cliente`, `Nombre_empleado`, `Fecha`, `SubTotal`, `Descuento`, `IVA`, `Total`, `Id_estado_eliminado`, `Id_estado_venta`) VALUES
(1, 1, 1, 'CRESENCIO MIGUEL CARBAJAL', '2021-01-04', '60', '0', '0', '60', 1, 2),
(2, 1, 2, 'CRESENCIO MIGUEL CARBAJAL', '2021-01-04', '45', '2', '0', '43', 1, 2),
(3, 2, 2, 'MARY CRUZ LOPEZ', '2021-01-04', '50', '0', '0', '50', 1, 2),
(4, 2, 2, 'MARY CRUZ LOPEZ', '2021-01-04', '50', '0', '0', '50', 1, 2),
(5, 1, 2, 'CRESENCIO MIGUEL CARBAJAL', '2021-01-05', '45', '0', '0', '45', 1, 2),
(6, 1, 2, 'CRESENCIO MIGUEL CARBAJAL', '2021-01-05', '110', '5', '0', '105', 2, 1),
(7, 2, 1, 'MARY CRUZ LOPEZ', '2021-01-05', '89', '-1', '0', '90', 1, 1),
(8, 2, 1, 'MARY CRUZ LOPEZ', '2021-01-05', '285', '2', '0', '283', 2, 1),
(9, 2, 2, 'MARY CRUZ LOPEZ', '2021-01-05', '60', '0', '0', '60', 2, 1),
(10, 2, 1, 'MARY CRUZ LOPEZ', '2021-01-06', '130', '1', '0', '129', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personas`
--

CREATE TABLE `personas` (
  `Id_persona` int(11) NOT NULL,
  `RFC` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `Nombre` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `Direccion` varchar(125) COLLATE utf8_spanish_ci NOT NULL,
  `Telefono` varchar(10) COLLATE utf8_spanish_ci NOT NULL,
  `Id_estado` int(11) NOT NULL,
  `Municipio` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `Id_estado_eliminado` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `personas`
--

INSERT INTO `personas` (`Id_persona`, `RFC`, `Nombre`, `Direccion`, `Telefono`, `Id_estado`, `Municipio`, `Id_estado_eliminado`) VALUES
(1, 'MICA990717', 'ALEJANDRO MIGUEL CRUZ', 'CARR. LIBRAMIENTO HACIA EL ORO', '7226661684', 1, 'VILLA VICTORIA', 1),
(2, 'GATD000113', 'DANIELA GARDUNO TAPIA', 'CARRETERA OCOTILLOS', '7226781567', 1, 'VILLA VICTORIA', 1),
(3, '13456789', 'CRESENCIO MIGUEL CARBAJAL', 'LIBRAMIENTO HACIA EL ORO', '7221522954', 1, 'VILLA VICTORIA', 1),
(4, '9889655', 'MARY CRUZ LOPEZ', 'AMANALCO DE BECERRA', '5523065555', 1, 'AMANALCO', 1),
(5, 'RELA990502', 'ALEXIS ORLANDO REBOLLAR LOPEZ', 'AV. FRANCISCO', '7228192355', 1, 'VALLE DE BRAVO', 1),
(6, 'RELA950429', 'ALAN OTHONIEL REBOLLAR LOPEZ', 'AV. FRANCISCO DE ASIS', '72221435', 1, 'VALLE DE BRAVO', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `Id_producto` int(11) NOT NULL,
  `Id_marca` int(11) NOT NULL,
  `Codigo` varchar(75) COLLATE utf8_spanish_ci NOT NULL,
  `Descripcion` varchar(125) COLLATE utf8_spanish_ci NOT NULL,
  `Id_unidad` int(11) NOT NULL,
  `Clasificacion` varchar(125) COLLATE utf8_spanish_ci NOT NULL,
  `Costo` decimal(10,0) NOT NULL,
  `Precio_venta` decimal(10,0) NOT NULL,
  `Precio_uno` decimal(10,0) NOT NULL,
  `Precio_dos` decimal(10,0) NOT NULL,
  `Precio_tres` decimal(10,0) NOT NULL,
  `Precio_cuatro` decimal(10,0) NOT NULL,
  `Lote` varchar(75) COLLATE utf8_spanish_ci NOT NULL,
  `fecha_actualizacion` date DEFAULT NULL,
  `Imagen` varchar(400) COLLATE utf8_spanish_ci NOT NULL,
  `Id_estado_eliminado` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`Id_producto`, `Id_marca`, `Codigo`, `Descripcion`, `Id_unidad`, `Clasificacion`, `Costo`, `Precio_venta`, `Precio_uno`, `Precio_dos`, `Precio_tres`, `Precio_cuatro`, `Lote`, `fecha_actualizacion`, `Imagen`, `Id_estado_eliminado`) VALUES
(1, 1, '123', 'SABRITAS LIMON 30GR', 1, 'PAPAS', '12', '15', '0', '0', '0', '15', 'L/', '2020-12-29', '', 1),
(2, 2, '798456', 'GANSITO 20GR', 1, 'DULCES', '7', '10', '10', '10', '10', '10', 'L/', '2020-12-29', '', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos_eliminados`
--

CREATE TABLE `productos_eliminados` (
  `Id_producto_eliminado` int(11) NOT NULL,
  `Id_producto` int(11) NOT NULL,
  `Fecha_eliminacion` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Disparadores `productos_eliminados`
--
DELIMITER $$
CREATE TRIGGER `Actualizar_Estado_Eliminado_Producto` AFTER INSERT ON `productos_eliminados` FOR EACH ROW begin
	declare vid_producto int;
    set vid_producto = 0;
    
	select Productos.id_producto into vid_producto from Productos, Productos_Eliminados where Productos.id_producto=Productos_Eliminados.id_producto
	and Productos_Eliminados.id_producto = new.id_producto limit 1;
	update productos set id_estado_eliminado = 2 where id_producto = vid_producto limit 1;
end
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `Id_proveedor` int(11) NOT NULL,
  `Id_persona` int(11) NOT NULL,
  `Id_empresa` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `proveedores`
--

INSERT INTO `proveedores` (`Id_proveedor`, `Id_persona`, `Id_empresa`) VALUES
(1, 6, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores_eliminados`
--

CREATE TABLE `proveedores_eliminados` (
  `Id_proveedor_eliminado` int(11) NOT NULL,
  `Id_proveedor` int(11) NOT NULL,
  `Fecha_eliminacion` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `unidad`
--

CREATE TABLE `unidad` (
  `Id_unidad` int(11) NOT NULL,
  `Descripcion` varchar(75) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `unidad`
--

INSERT INTO `unidad` (`Id_unidad`, `Descripcion`) VALUES
(1, 'PZS');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `Id_usuario` int(11) NOT NULL,
  `Nombre` varchar(100) COLLATE utf8_spanish_ci NOT NULL,
  `Contrasenia` varchar(75) COLLATE utf8_spanish_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `Id_venta` int(11) NOT NULL,
  `Id_nota_venta` int(11) NOT NULL,
  `Id_producto` int(11) NOT NULL,
  `Cantidad` int(11) NOT NULL,
  `Descripcion` varchar(125) COLLATE utf8_spanish_ci NOT NULL,
  `Unidad` varchar(50) COLLATE utf8_spanish_ci NOT NULL,
  `Precio` decimal(10,0) NOT NULL,
  `Descuento` decimal(10,0) NOT NULL,
  `SubTotal` decimal(10,0) NOT NULL,
  `Total` decimal(10,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`Id_venta`, `Id_nota_venta`, `Id_producto`, `Cantidad`, `Descripcion`, `Unidad`, `Precio`, `Descuento`, `SubTotal`, `Total`) VALUES
(1, 1, 1, 4, 'SABRITAS LIMON 30GR', 'PZS', '15', '0', '60', '60'),
(2, 2, 1, 3, 'SABRITAS LIMON 30GR', 'PZS', '15', '4', '45', '43'),
(3, 3, 2, 5, 'GANSITO 20GR', 'PZS', '10', '0', '50', '50'),
(4, 4, 2, 5, 'GANSITO 20GR', 'PZS', '10', '0', '50', '50'),
(5, 5, 1, 3, 'SABRITAS LIMON 30GR', 'PZS', '15', '0', '45', '45'),
(6, 6, 2, 6, 'GANSITO 20GR', 'PZS', '10', '8', '60', '55'),
(8, 8, 1, 10, 'SABRITAS LIMON 30GR', 'PZS', '15', '0', '150', '150'),
(9, 8, 2, 3, 'GANSITO 20GR', 'PZS', '10', '8', '30', '28'),
(10, 8, 1, 1, 'SABRITAS LIMON 30GR', 'PZS', '15', '0', '15', '15'),
(11, 9, 2, 2, 'GANSITO 20GR', 'PZS', '10', '0', '20', '20'),
(12, 6, 2, 1, 'GANSITO 20GR', 'PZS', '10', '0', '10', '10'),
(13, 7, 1, 4, 'SABRITAS LIMON 30GR', 'PZS', '15', '0', '60', '60'),
(14, 10, 2, 4, 'GANSITO 20GR', 'PZS', '10', '0', '40', '40'),
(16, 10, 1, 2, 'SABRITAS LIMON 30GR', 'PZS', '15', '0', '30', '30'),
(17, 10, 1, 4, 'SABRITAS LIMON 30GR', 'PZS', '15', '2', '60', '59');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas_eliminadas`
--

CREATE TABLE `ventas_eliminadas` (
  `Id_venta_eliminada` int(11) NOT NULL,
  `Id_nota_venta` int(11) NOT NULL,
  `Fecha_eliminacion` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

--
-- Volcado de datos para la tabla `ventas_eliminadas`
--

INSERT INTO `ventas_eliminadas` (`Id_venta_eliminada`, `Id_nota_venta`, `Fecha_eliminacion`) VALUES
(1, 9, '2021-01-06'),
(2, 8, '2021-01-06'),
(3, 6, '2021-01-06');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `almacenes`
--
ALTER TABLE `almacenes`
  ADD PRIMARY KEY (`Id_almacen`);

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`Id_cliente`),
  ADD KEY `clientes_ibfk_1` (`Id_persona`);

--
-- Indices de la tabla `clientes_eliminados`
--
ALTER TABLE `clientes_eliminados`
  ADD PRIMARY KEY (`Id_cliente_eliminado`),
  ADD KEY `clientes_eliminados_ibfk_1` (`Id_cliente`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`Id_empleado`),
  ADD KEY `empleados_ibfk_1` (`Id_persona`);

--
-- Indices de la tabla `empleados_eliminados`
--
ALTER TABLE `empleados_eliminados`
  ADD PRIMARY KEY (`Id_empleado_eliminado`),
  ADD KEY `empleados_eliminados_ibfk_1` (`Id_empleado`);

--
-- Indices de la tabla `empresa`
--
ALTER TABLE `empresa`
  ADD PRIMARY KEY (`Id_empresa`);

--
-- Indices de la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD PRIMARY KEY (`Id_entrada`),
  ADD KEY `entradas_ibfk_1` (`Id_almacen`),
  ADD KEY `entradas_ibfk_2` (`Id_producto`);

--
-- Indices de la tabla `estados_republica`
--
ALTER TABLE `estados_republica`
  ADD PRIMARY KEY (`Id_estado`),
  ADD UNIQUE KEY `Descripcion` (`Descripcion`);

--
-- Indices de la tabla `estado_eliminado`
--
ALTER TABLE `estado_eliminado`
  ADD PRIMARY KEY (`Id_estado_eliminado`);

--
-- Indices de la tabla `estado_nota_venta`
--
ALTER TABLE `estado_nota_venta`
  ADD PRIMARY KEY (`Id_estado_venta`);

--
-- Indices de la tabla `marcas`
--
ALTER TABLE `marcas`
  ADD PRIMARY KEY (`Id_marca`),
  ADD UNIQUE KEY `Descripcion` (`Descripcion`);

--
-- Indices de la tabla `nota_ventas`
--
ALTER TABLE `nota_ventas`
  ADD PRIMARY KEY (`Id_nota_venta`),
  ADD KEY `nota_ventas_ibfk_1` (`Id_cliente`),
  ADD KEY `nota_ventas_ibfk_2` (`Id_empleado`),
  ADD KEY `nota_ventas_ibfk_3` (`Id_estado_eliminado`);

--
-- Indices de la tabla `personas`
--
ALTER TABLE `personas`
  ADD PRIMARY KEY (`Id_persona`),
  ADD UNIQUE KEY `RFC` (`RFC`),
  ADD KEY `personas_ibfk_1` (`Id_estado`),
  ADD KEY `personas_ibfk_2` (`Id_estado_eliminado`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`Id_producto`),
  ADD UNIQUE KEY `Codigo` (`Codigo`),
  ADD KEY `productos_ibfk_1` (`Id_marca`),
  ADD KEY `productos_ibfk_2` (`Id_unidad`),
  ADD KEY `productos_ibfk_3` (`Id_estado_eliminado`);

--
-- Indices de la tabla `productos_eliminados`
--
ALTER TABLE `productos_eliminados`
  ADD PRIMARY KEY (`Id_producto_eliminado`),
  ADD KEY `productos_eliminados_ibfk_1` (`Id_producto`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`Id_proveedor`),
  ADD KEY `proveedores_ibfk_1` (`Id_persona`),
  ADD KEY `proveedores_ibfk_2` (`Id_empresa`);

--
-- Indices de la tabla `proveedores_eliminados`
--
ALTER TABLE `proveedores_eliminados`
  ADD PRIMARY KEY (`Id_proveedor_eliminado`),
  ADD KEY `proveedores_eliminados_ibfk_1` (`Id_proveedor`);

--
-- Indices de la tabla `unidad`
--
ALTER TABLE `unidad`
  ADD PRIMARY KEY (`Id_unidad`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`Id_usuario`),
  ADD UNIQUE KEY `Nombre` (`Nombre`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`Id_venta`),
  ADD KEY `ventas_ibfk_1` (`Id_producto`),
  ADD KEY `ventas_ibfk_2` (`Id_nota_venta`);

--
-- Indices de la tabla `ventas_eliminadas`
--
ALTER TABLE `ventas_eliminadas`
  ADD PRIMARY KEY (`Id_venta_eliminada`),
  ADD KEY `ventas_eliminadas_ibfk_1` (`Id_nota_venta`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `almacenes`
--
ALTER TABLE `almacenes`
  MODIFY `Id_almacen` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `Id_cliente` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `clientes_eliminados`
--
ALTER TABLE `clientes_eliminados`
  MODIFY `Id_cliente_eliminado` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `Id_empleado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `empleados_eliminados`
--
ALTER TABLE `empleados_eliminados`
  MODIFY `Id_empleado_eliminado` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `empresa`
--
ALTER TABLE `empresa`
  MODIFY `Id_empresa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `entradas`
--
ALTER TABLE `entradas`
  MODIFY `Id_entrada` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `estados_republica`
--
ALTER TABLE `estados_republica`
  MODIFY `Id_estado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `estado_eliminado`
--
ALTER TABLE `estado_eliminado`
  MODIFY `Id_estado_eliminado` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `estado_nota_venta`
--
ALTER TABLE `estado_nota_venta`
  MODIFY `Id_estado_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `marcas`
--
ALTER TABLE `marcas`
  MODIFY `Id_marca` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `nota_ventas`
--
ALTER TABLE `nota_ventas`
  MODIFY `Id_nota_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `personas`
--
ALTER TABLE `personas`
  MODIFY `Id_persona` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `Id_producto` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `productos_eliminados`
--
ALTER TABLE `productos_eliminados`
  MODIFY `Id_producto_eliminado` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `Id_proveedor` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `proveedores_eliminados`
--
ALTER TABLE `proveedores_eliminados`
  MODIFY `Id_proveedor_eliminado` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `unidad`
--
ALTER TABLE `unidad`
  MODIFY `Id_unidad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `Id_usuario` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `Id_venta` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `ventas_eliminadas`
--
ALTER TABLE `ventas_eliminadas`
  MODIFY `Id_venta_eliminada` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD CONSTRAINT `clientes_ibfk_1` FOREIGN KEY (`Id_persona`) REFERENCES `personas` (`Id_persona`);

--
-- Filtros para la tabla `clientes_eliminados`
--
ALTER TABLE `clientes_eliminados`
  ADD CONSTRAINT `clientes_eliminados_ibfk_1` FOREIGN KEY (`Id_cliente`) REFERENCES `clientes` (`Id_cliente`);

--
-- Filtros para la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD CONSTRAINT `empleados_ibfk_1` FOREIGN KEY (`Id_persona`) REFERENCES `personas` (`Id_persona`);

--
-- Filtros para la tabla `empleados_eliminados`
--
ALTER TABLE `empleados_eliminados`
  ADD CONSTRAINT `empleados_eliminados_ibfk_1` FOREIGN KEY (`Id_empleado`) REFERENCES `empleados` (`Id_empleado`);

--
-- Filtros para la tabla `entradas`
--
ALTER TABLE `entradas`
  ADD CONSTRAINT `entradas_ibfk_1` FOREIGN KEY (`Id_almacen`) REFERENCES `almacenes` (`Id_almacen`),
  ADD CONSTRAINT `entradas_ibfk_2` FOREIGN KEY (`Id_producto`) REFERENCES `productos` (`Id_producto`);

--
-- Filtros para la tabla `nota_ventas`
--
ALTER TABLE `nota_ventas`
  ADD CONSTRAINT `nota_ventas_ibfk_1` FOREIGN KEY (`Id_cliente`) REFERENCES `clientes` (`Id_cliente`),
  ADD CONSTRAINT `nota_ventas_ibfk_2` FOREIGN KEY (`Id_empleado`) REFERENCES `empleados` (`Id_empleado`),
  ADD CONSTRAINT `nota_ventas_ibfk_3` FOREIGN KEY (`Id_estado_eliminado`) REFERENCES `estado_eliminado` (`Id_estado_eliminado`);

--
-- Filtros para la tabla `personas`
--
ALTER TABLE `personas`
  ADD CONSTRAINT `personas_ibfk_1` FOREIGN KEY (`Id_estado`) REFERENCES `estados_republica` (`Id_estado`),
  ADD CONSTRAINT `personas_ibfk_2` FOREIGN KEY (`Id_estado_eliminado`) REFERENCES `estado_eliminado` (`Id_estado_eliminado`);

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`Id_marca`) REFERENCES `marcas` (`Id_marca`),
  ADD CONSTRAINT `productos_ibfk_2` FOREIGN KEY (`Id_unidad`) REFERENCES `unidad` (`Id_unidad`),
  ADD CONSTRAINT `productos_ibfk_3` FOREIGN KEY (`Id_estado_eliminado`) REFERENCES `estado_eliminado` (`Id_estado_eliminado`);

--
-- Filtros para la tabla `productos_eliminados`
--
ALTER TABLE `productos_eliminados`
  ADD CONSTRAINT `productos_eliminados_ibfk_1` FOREIGN KEY (`Id_producto`) REFERENCES `productos` (`Id_producto`);

--
-- Filtros para la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD CONSTRAINT `proveedores_ibfk_1` FOREIGN KEY (`Id_persona`) REFERENCES `personas` (`Id_persona`),
  ADD CONSTRAINT `proveedores_ibfk_2` FOREIGN KEY (`Id_empresa`) REFERENCES `empresa` (`Id_empresa`);

--
-- Filtros para la tabla `proveedores_eliminados`
--
ALTER TABLE `proveedores_eliminados`
  ADD CONSTRAINT `proveedores_eliminados_ibfk_1` FOREIGN KEY (`Id_proveedor`) REFERENCES `proveedores` (`Id_proveedor`);

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`Id_producto`) REFERENCES `productos` (`Id_producto`),
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`Id_nota_venta`) REFERENCES `nota_ventas` (`Id_nota_venta`);

--
-- Filtros para la tabla `ventas_eliminadas`
--
ALTER TABLE `ventas_eliminadas`
  ADD CONSTRAINT `ventas_eliminadas_ibfk_1` FOREIGN KEY (`Id_nota_venta`) REFERENCES `nota_ventas` (`Id_nota_venta`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
