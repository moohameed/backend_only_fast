import { response } from 'express';
import pool from '../Database/mysql.js';


export const addNewOrders = async (req, res = response ) => {

    try {

        const { uidAddress, total,  products } = req.body;
        //console.log(req.body.products[0].ingredients.last)
        const orderdb = await pool.query('INSERT INTO orders (client_id, address_id, price) VALUES (?,?,?)', [ req.uid, uidAddress, total ]);
        products.forEach(async (element) => {
            
            const orderprod = await pool.query('INSERT INTO order_products (order_id, product_id, quantity, price) VALUES (?,?,?,?)',  [ orderdb.insertId, element.id, element.quantity, element.totalPrice ]);
            element.ingredients.forEach((ingredient) => {
                ingredient.listIngredients.forEach(detail => {
                    pool.query('insert into order_ingredients (order_product_id, ingredient_id) values (?,?)', [orderprod.insertId, detail.id])
                })
            })
        });
        res.json({
            resp: true,
            insertId: orderdb.insertId,
            msg : 'New Order added successfully'
        });

    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const getOrdersByStatus = async (req, res = response ) => {
    var ordersResponse = []
    try {
        const informations = await pool.query(
            'SELECT ord.orderId, ord.price, c.firstName, c.lastName, c.phone as client_phone, ord.date, ord.address_id ,ord.status from orders ord, person c where ord.client_id = c.uid and ord.status = ?;',
            [req.params.statusOrder]
        );
    
        for (const order of informations) {
            const prod_details = await pool.query(
                'SELECT ordProd.id, pro.nameProduct, ordProd.quantity, ordProd.price, resto.name as resot_name, resto.phone as retaurant_phone, resto.address as restaurant_address FROM restaurants resto, order_products ordProd, products pro where ordProd.product_id = pro.id and resto.id = pro.restaurant_id and ordProd.order_id = ?;',
                [order.orderId]
            );
    
            order['products'] = [];
    
            for (const product of prod_details) {
                const ingredients = await pool.query(
                    'SELECT typeIng.label as type_label, ing.label from ingredients ing, ingredient_type typeIng, order_ingredients ordIng WHERE ing.id = ordIng.ingredient_id and ing.type_id = typeIng.id and ordIng.order_product_id = ?;',
                    [product.id]
                );

    
                product['ingredients'] = ingredients;
                order['products'].push(product);
            }
            const address = await pool.query(
                `SELECT * from addresses where id = ${order.address_id};`
            );
            order["address"] = address[0]
            
            
            ordersResponse.push(order);
        }
    
        console.log(ordersResponse);
    
        return res.json({
            resp: true,
            msg: 'Orders by ' + req.params.statusOrder,
            ordersResponse: ordersResponse,
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const getDetailsOrderById = async ( req, res = response ) => {

    try {

        const detailOrderdb = await pool.query(`CALL SP_ORDER_DETAILS(?);`, [ req.params.idOrderDetails ]);

        res.json({
            resp: true,
            msg : 'Order details by ' + req.params.idOrderDetails,
            detailsOrder: detailOrderdb[0]
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const updateOrderStatusToDispatched = async ( req, res = response ) => {

    try {

        const { idDelivery, idOrder, status } = req.body;

        await pool.query('UPDATE orders SET status = ?, delivery_id = ? WHERE orderId = ?', [ status, idDelivery, idOrder ]);

        res.json({
            resp: true,
            msg : 'Order DISPATCHED'
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const updateOrderStatus = async ( req, res = response ) => {

    try {

        const { idOrder, status } = req.body;

        await pool.query('UPDATE orders SET status = ? WHERE orderId = ?', [ status, idOrder ]);

        res.json({
            resp: true,
            msg : 'Order Status Updated'
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const getOrdersByDelivery = async ( req, res = response ) => {

    var ordersResponse = []
    try {
        const informations = await pool.query(
            'SELECT ord.orderId, ord.price, ord.address_id, c.firstName, c.lastName, c.phone as client_phone, ord.date,  ord.status from orders ord, person c where ord.client_id = c.uid and ord.status = ? and ord.delivery_id=?;',
            [req.params.statusOrder, req.params.deliveryId]
        );
    
        for (const order of informations) {
            const prod_details = await pool.query(
                'SELECT ordProd.id, pro.nameProduct, ordProd.quantity, ordProd.price, resto.name as resot_name, resto.phone as retaurant_phone, resto.address as restaurant_address FROM restaurants resto, order_products ordProd, products pro where ordProd.product_id = pro.id and resto.id = pro.restaurant_id and ordProd.order_id = ?;',
                [order.orderId]
            );
    
            order['products'] = [];
    
            for (const product of prod_details) {
                const ingredients = await pool.query(
                    'SELECT typeIng.label as type_label, ing.label from ingredients ing, ingredient_type typeIng, order_ingredients ordIng WHERE ing.id = ordIng.ingredient_id and ing.type_id = typeIng.id and ordIng.order_product_id = ?;',
                    [product.id]
                );
    
                product['ingredients'] = ingredients;
                order['products'].push(product);
            }
            const address = await pool.query(
                `SELECT * from addresses where id = ${order.address_id};`
            );
            order["address"] = address[0]
    
            ordersResponse.push(order);
        }
    
        console.log(ordersResponse);
    
        return res.json({
            resp: true,
            msg: 'Orders by ' + req.params.statusOrder,
            ordersResponse: ordersResponse,
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }
}

export const updateStatusToOntheWay = async ( req, res = response ) => {

    try {

        const { latitude, longitude } = req.body;

        await pool.query('UPDATE orders SET status = ?, latitude = ?, longitude = ? WHERE id = ?', ['ON WAY', latitude, longitude, req.params.idOrder ]);

        res.json({
            resp: true,
            msg : 'ON WAY'
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const updateStatusToDelivered = async ( req, res = response ) => {

    try {

        await pool.query('UPDATE orders SET status = ? WHERE id = ?', ['DELIVERED', req.params.idOrder ]);

        res.json({
            resp: true,
            msg : 'ORDER DELIVERED'
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}


async function test (){
    const informations = await pool.query('SELECT ord.orderId, ord.price, c.firstName, c.lastName, c.phone as client_phone, resto.name as resot_name, resto.phone as retaurant_phone, resto.address as restaurant_address from orders ord, person c, restaurants resto where ord.client_id = c.uid and ord.address_id = resto.id and ord.status = ?;', [ req.params.statusOrder ])
        informations.forEach(async (order) => {
            order ['products'] = []
            const prod_details = await pool.query('SELECT ordProd.id, pro.nameProduct, ordProd.quantity FROM order_products ordProd, products pro where ordProd.product_id = pro.id and ordProd.order_id = ?;', [order.orderId])
            prod_details.forEach(async (product) => {
                product['ingredients'] = []
                const ingredients = await pool.query('SELECT typeIng.label as type_label, ing.label from ingredients ing, ingredient_type typeIng, order_ingredients ordIng WHERE ing.id = ordIng.ingredient_id and ing.type_id = typeIng.id and ordIng.order_product_id = ?;', [product.id])
                ingredients.forEach((element) => {
                    product['ingredients'].push(element)

                })
                
                order ['products'].push(product)

                
            })
        })
        return order
}