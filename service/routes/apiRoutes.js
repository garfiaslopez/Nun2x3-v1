 'use strict';

//  Module dependencies.
var UserFunctions = require("../controllers/userController");
var CarwashFunctions = require("../controllers/carwashController");
var CarFunctions = require("../controllers/carController");
var ServiceFunctions = require("../controllers/serviceController");
var ProductFunctions = require("../controllers/productController");
var SpendFunctions = require("../controllers/spendController");
var IngressFunctions = require("../controllers/ingressController");
var PaybillFunctions = require("../controllers/paybillController");
var StockFunctions = require("../controllers/stockController");
var TicketFunctions = require("../controllers/ticketController");
var ActiveTicketFunctions = require("../controllers/activeticketController");
var HistoryFunctions = require("../controllers/historyController");
var CorteFunctions = require("../controllers/corteController");
var PendingFunctions = require("../controllers/pendingController");

var AuthenticateFunctions = require("../controllers/authController");
var MiddleAuth = require('./../middlewares/auth');

module.exports = function(server) {

    //  Redirect request to controller
    server.post('/authenticate',AuthenticateFunctions.AuthByUser);

    //the routes put before the middleware does not is watched.
    server.use(MiddleAuth.isAuthenticated);

    server.get('/authenticate/me',AuthenticateFunctions.InfoUser);

	//LAVADO ROUTES:
	server.post('/carwash',CarwashFunctions.AddNewLavado);

	server.get('/carwash/:lavado_id',CarwashFunctions.SearchLavadoById);
	server.put('/carwash/:lavado_id',CarwashFunctions.UpdateLavadoById);
	server.del('/carwash/:lavado_id',CarwashFunctions.DeleteLavadoById);

	server.get('/carwashes',CarwashFunctions.AllLavados);
	server.get('/carwashes/:user_id',CarwashFunctions.AllLavadosByAccount);

	//USERS ROUTESkey: "value",
	server.post('/user',UserFunctions.AddNewUser);

	server.get('/user/:user_id',UserFunctions.SearchUserById);
	server.put('/user/:user_id',UserFunctions.UpdateUserById);
	server.del('/user/:user_id',UserFunctions.DeleteUserById);

	server.post('/user/tokenme',UserFunctions.InfoUserByToken);

	server.get('/users',UserFunctions.AllUsers);
	server.get('/users/:lavado_id',UserFunctions.AllUsersByLavado);
    server.get('/users/withToken/:lavado_id',UserFunctions.AllUsersByLavadoWithToken);
    server.get('/users/byAccount/:user_id',UserFunctions.AllUsersByAccount);


	//CAR ROUTES:
	server.post('/car',CarFunctions.AddNewCar);

	server.get('/car/:car_id',CarFunctions.SearchCarById);
	server.put('/car/:car_id',CarFunctions.UpdateCarById);
	server.del('/car/:car_id',CarFunctions.DeleteCarById);

	server.get('/cars',CarFunctions.AllCars);
	server.get('/cars/:lavado_id',CarFunctions.AllCarsByLavado);


	//SERVICE ROUTES:

	server.post('/service',ServiceFunctions.AddNewService);

	server.get('/service/:service_id',ServiceFunctions.SearchServiceById);
	server.put('/service/:service_id',ServiceFunctions.UpdateServiceById);
	server.del('/service/:service_id',ServiceFunctions.DeleteServiceById);

	server.get('/services',ServiceFunctions.AllServices);
	server.get('/services/:lavado_id',ServiceFunctions.AllServicesByLavado);

	//PRODUCT ROUTES:
	server.post('/product',ProductFunctions.AddNewProduct);

	server.get('/product/:product_id',ProductFunctions.SearchProductById);
	server.put('/product/:product_id',ProductFunctions.UpdateProductById);
	server.del('/product/:product_id',ProductFunctions.DeleteProductById);

	server.get('/products',ProductFunctions.AllProducts);


	//SPEND CONTROLLER:
	server.post('/spend',SpendFunctions.AddNewSpend);
	server.get('/spend/:spend_id',SpendFunctions.SearchSpendById);
	server.put('/spend/:spend_id',SpendFunctions.UpdateSpendById);
	server.del('/spend/:spend_id',SpendFunctions.DeleteSpendById);

	server.get('/spends',SpendFunctions.AllSpends);
	server.post('/spends/:lavado_id',SpendFunctions.AllSpendsByLavado);
    server.post('/spends/byAccount/:user_id',SpendFunctions.AllSpendsByAccount);


	//INGRESS CONTROLLER;
	server.post('/ingress',IngressFunctions.AddNewIngress);
	server.get('/ingress/:ingress_id',IngressFunctions.SearchIngressById);
	server.put('/ingress/:ingress_id',IngressFunctions.UpdateIngressById);
	server.del('/ingress/:ingress_id',IngressFunctions.DeleteIngressById);

	server.get('/ingresses',IngressFunctions.AllIngresses);
	server.post('/ingresses/:lavado_id',IngressFunctions.AllIngressesByLavado);
	server.post('/ingresses/byAccount/:user_id',IngressFunctions.AllIngressesByAccount);


	//STOCK CONTROLLER:

	server.post('/stock',StockFunctions.AddNewStock);
	server.get('/stock/:stock_id',StockFunctions.SearchStockById);
	server.put('/stock/:stock_id',StockFunctions.UpdateStockById);
	server.del('/stock/:stock_id',StockFunctions.DeleteStockById);

	server.get('/stocks',StockFunctions.AllStocks);
	server.post('/stocks/:lavado_id',StockFunctions.AllStocksByLavado);
	server.post('/stocks/byAccount/:user_id',StockFunctions.AllStocksByAccount);


	//PAYBILL CONTROLLER:

	server.post('/paybill',PaybillFunctions.AddNewPaybill);
	server.get('/paybill/:paybill_id',PaybillFunctions.SearchPaybillById);
	server.put('/paybill/:paybill_id',PaybillFunctions.UpdatePaybillById);
	server.del('/paybill/:paybill_id',PaybillFunctions.DeletePaybillById);

	server.get('/paybills',PaybillFunctions.AllPaybills);
	server.post('/paybills/:lavado_id',PaybillFunctions.AllPaybillsByLavado);
	server.post('/paybills/byAccount/:user_id',PaybillFunctions.AllPaybillsByAccount);

	//TICKET CONTROLLER:
	server.post('/ticket',TicketFunctions.AddNewTicket);
	server.get('/ticket/:ticket_id',TicketFunctions.SearchTicketById);
	server.put('/ticket/:ticket_id',TicketFunctions.UpdateTicketById);
	server.del('/ticket/:ticket_id',TicketFunctions.DeleteTicketById);

	server.get('/tickets',TicketFunctions.AllTickets);
	server.post('/tickets/:lavado_id',TicketFunctions.AllTicketsByLavado);
	server.post('/tickets/byAccount/:user_id',TicketFunctions.AllTicketsByAccount);

	server.post('/activeticket',ActiveTicketFunctions.AddNewActiveTicket);
	server.get('/activeticket/:ticket_id',ActiveTicketFunctions.SearchActiveTicketById);
	server.put('/activeticket/:ticket_id',ActiveTicketFunctions.UpdateActiveTicketById);
	server.del('/activeticket/:ticket_id',ActiveTicketFunctions.DeleteActiveTicketById);
	server.del('/activeticket/:lavado_id/byindex/:indexpath',ActiveTicketFunctions.DeleteActiveTicketByIndex);

	server.get('/activetickets',ActiveTicketFunctions.AllActiveTickets);
	server.get('/activetickets/:lavado_id',ActiveTicketFunctions.AllActiveTicketsByLavado);
	server.post('/activetickets/byAccount/:user_id',ActiveTicketFunctions.AllActiveTicketsByAccount);
    server.del('/activetickets/:lavado_id',ActiveTicketFunctions.DeleteActiveTicketsByLavado);

	//HISTORY CONTROLLER:
	server.post('/history/:lavado_id',HistoryFunctions.AllHistoryByLavado);
    server.post('/history/update/:lavado_id',HistoryFunctions.UpdateByLavado);
    server.del('/history/delete',HistoryFunctions.DeleteById);

    //DASHBOARD CONTROLLER:
    server.post('/dashboard/:lavado_id',HistoryFunctions.DashboardByLavado);

    //CORTE CONTROLLER;
    server.post('/corte',CorteFunctions.AddNewCorte);
	server.get('/corte/:corte_id',CorteFunctions.SearchCorteById);
	server.put('/corte/:corte_id',CorteFunctions.UpdateCorteById);
	server.del('/corte/:ticket_id',CorteFunctions.DeleteCorteById);
    server.get('/corte/last/:lavado_id',CorteFunctions.LastCorteByLavado);

	server.get('/cortes',CorteFunctions.AllCortes);
    server.get('/cortes/:lavado_id',CorteFunctions.AllCortesByLavado);
	//server.post('/cortes/byAccount/:user_id',CorteFunctions.AllCortesByAccount);

    //PENDING CONTROLLER
    server.post('/pending',PendingFunctions.Create);
    server.get('/pending/:ingress_id',PendingFunctions.ById);
    server.put('/pending/:pending_id',PendingFunctions.Update);
    server.del('/pending/:pending_id',PendingFunctions.Delete);

    server.get('/pendings',PendingFunctions.All);
    server.get('/pendings/:lavado_id',PendingFunctions.AllByLavado);

};
