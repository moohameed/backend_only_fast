import { response } from 'express';
import pool from '../Database/mysql.js';


export const addNewProduct = async (req, res = response) => {

    try {

        const { name, description, price, category } = req.body;
        
        const rows = await pool.query('INSERT INTO products (nameProduct, description, price, category_id) VALUE (?,?,?,?)', [name, description, price, category]);
        
        req.files.forEach(image => {
            pool.query('INSERT INTO imageProduct (picture, product_id) value (?,?)', [ image.filename, rows.insertId ]);
        });

        return res.json({
            resp: true,
            msg : 'Product added Successfully'
        });

    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const getProductsTopHome = async (req, res = response) => {
    if(req.params.categoryId[1] == '-')
    {
        try {
            const productsdb = await pool.query(`CALL SP_GET_PRODUCTS_TOP(?);`, req.params.idRestaurant.slice(1));
            return res.json({
                resp: true,
                msg : 'Products',
                productsdb: productsdb[0] 
            });
    
            
        } catch (e) {
            return res.status(500).json({
                resp: false,
                msg : e
            });
        }
    }

    else
    {
        try {
            const productsdb = await pool.query(`CALL SP_GET_PRODUCTS_CATEGORY(${req.params.idRestaurant.slice(1)},${req.params.categoryId.slice(1)});`);
            return res.json({
                resp: true,
                msg : 'Top 10 Products',
                productsdb: productsdb[0] 
            });
    
            
        } catch (e) {
            return res.status(500).json({
                resp: false,
                msg : e
            });
        }
    }

    
}

export const getImagesProduct = async ( req, res = response ) => {

    try {
        console.log(req.params.id.substring(1,req.params.id.length))
        const imageProductdb = await pool.query('SELECT picture FROM products WHERE id = ?',req.params.id.slice(1));

        return res.json({
            resp: true,
            msg : 'Get Images Products',
            imageProductdb: imageProductdb
        });
        
    } catch (e) {
        console.log('no')
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const searchProductForName = async (req, res = response) => {

    try {

        const productdb = await pool.query(`CALL SP_SEARCH_PRODUCT(?);`, [ req.params.nameProduct ]);

        res.json({
            resp: true,
            msg : 'Search products',
            productsdb: productdb[0]
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const searchProductsForCategory = async (req, res = response) => {

    try {

        const productdb = await pool.query(`CALL SP_SEARCH_FOR_CATEGORY(?);`, [req.params.idCategory]);

        res.json({
            resp: true,
            msg : 'list Products for id Category',
            productsdb : productdb[0]
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const listProductsAdmin = async (req, res = response) => {

    try {

        const productsdb = await pool.query(`CALL SP_LIST_PRODUCTS_ADMIN();`);

        res.json({
            resp: true,
            msg : 'Top 10 Products',
            productsdb: productsdb[0] 
        });

        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }
}

export const updateStatusProduct = async (req, res = response) => {

    try {

        const { status, idProduct } = req.body;

        await pool.query('UPDATE products SET status = ? WHERE id = ?', [ parseInt(status), parseInt(idProduct) ]);

        res.json({
            resp: true,
            msg : 'Product updated'
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}

export const deleteProduct = async (req, res = response ) => {

    try {

        await pool.query('DELETE FROM imageProduct WHERE product_id = ?', [ req.params.idProduct ]);
        await pool.query('DELETE FROM products WHERE id = ?', [ req.params.idProduct ]);

        res.json({
            resp: true,
            msg : 'Product deleted successfully'
        });
        
    } catch (e) {
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}


export const getIngredients = async ( req, res = response ) => {

    try {
        const ingredients = [];
        const productIngredientTypes = await pool.query('SELECT ingType.label, ingType.id, ingProd.possible_choices from ingredient_type ingType, product_ingredients ingProd WHERE ingType.id = ingProd.ingredient_type and ingProd.product_id = ?',req.params.id.slice(1));
        for (let i = 0; i < productIngredientTypes.length; i++)
        {
            const labelType = productIngredientTypes[i]['label']
            const nbChoices = productIngredientTypes[i]['possible_choices']
            const labledIngredient = {}
            const ingList = []
            const productIngredients = await pool.query('select ing.id, ing.label, restoIng.price from ingredients ing, restaurant_ingredients restoIng where ing.id = restoIng.ingredient_id and restoIng.restaurant_id = ? and ing.type_id =? ',[req.params.restoId.slice(1), productIngredientTypes[i]['id']])
            productIngredients.forEach((x)=> ingList.push({'id':x['id'] ,'label':x['label'], 'price':x['price']}))
            labledIngredient['type'] = labelType
            labledIngredient['listIngredients'] = ingList
            labledIngredient['nbChoices'] = nbChoices
            ingredients.push(labledIngredient)
        }
        console.log(ingredients)
        return res.json({
            resp: true,
            msg : 'Get Product Ingredients',
            productIngredientsdb: ingredients
        });
        
    } catch (e) {
        console.log('no')
        return res.status(500).json({
            resp: false,
            msg : e
        });
    }

}