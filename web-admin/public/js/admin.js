var app = angular.module('AdminApp',['RouterCtrl','AuthService','CarwashService','ngMaterial','md.data.table','ngSanitize','btford.socket-io']);

app.config(function($mdIconProvider, $httpProvider, $mdThemingProvider){

    $mdIconProvider
        .icon("menu", "../public/images/icons/menu.svg"        , 24)
        .icon("user", "../public/images/icons/account4.svg"    , 24)
        .icon("section", "../public/images/icons/bed24.svg"    , 24)
        .icon("commercial", "../public/images/icons/google128.svg"    , 24)
        .icon("pack", "../public/images/icons/work3.svg"    , 24)
        .icon("commercializer", "../public/images/icons/emoticon117.svg"    , 24)
        .icon("cars", "../public/images/icons/front16.svg"    , 24)
        .icon("receipt", "../public/images/icons/receipt.svg"    , 24)
        .icon("dasboard", "../public/images/Dasboard.svg"    , 24)
        .icon("billing", "../public/images/Facturacion.svg"    , 24)
        .icon("spends", "../public/images/Gastos.svg"    , 24)
        .icon("historial", "../public/images/Historial.svg"    , 24)
        .icon("ingresses", "../public/images/Ingresos.svg"    , 24)
        .icon("services", "../public/images/icons/circles23.svg"    , 24)
        .icon("paybills", "../public/images/Vales.svg"    , 24)
        .icon("ticket", "../public/images/Ticket.svg"    , 24)
        .icon("Ticket", "../public/images/Ticket.svg"    , 400)
        .icon("carwashes", "../public/images/icons/front17.svg"    , 24)
        .icon("products", "../public/images/Ticket.svg"    , 24)
        .icon("delete", "../public/images/icons/cancel19.svg"    , 24)
        .icon("userlogin", "../public/images/icons/account4.svg"    , 120)
        .icon("logout", "../public/images/icons/thermostat1.svg"    , 120)
        .icon("configurations", "../public/images/icons/settings49.svg"    , 120)
        .icon("usercircle", "../public/images/icons/round58.svg"    , 120);



    $httpProvider.interceptors.push('AuthInterceptor');

    $mdThemingProvider.theme('default')
        .primaryPalette('blue')
        .accentPalette('red');


});

app.controller('MainController',function($rootScope,$location,$scope,$mdSidenav,Auth,CarwashServ,CarwashVars){

    $scope.Profile = {
        name: "Usuario",
        rol: "Nivel",
    };

    if(Auth.isLoggedIn()){
        console.log("islogged");
        $location.path("/Dashboard");
        $scope.Tittle = "Dashboard";
    }else{
        window.location = '/Login';
    }

    MenuList = [
        {
            name:"Dashboard",
            icon:"section",
            route:"/Dashboard",
            selected: true

        },
        {
            name:"Lavados",
            icon:"carwashes",
            route:"/Carwash",
            selected: false

        },
        {
            name:"Usuarios",
            icon:"user",
            route:"/Users",
            selected: false

        },
        {
            name:"Autos",
            icon:"cars",
            route:"/Cars",
            selected: false

        },
        {
            name:"Servicios",
            icon:"services",
            route:"/Services",
            selected: false

        },
        {
            name:"Productos",
            icon:"products",
            route:"/Products",
            selected: false

        },
        {
            name:"Historial",
            icon:"historial",
            route:"/History",
            selected: false

        },
        {
            name:"Gastos",
            icon:"spends",
            route:"/Spends",
            selected: false

        },
        {
            name:"Ingresos",
            icon:"ingresses",
            route:"/Ingress",
            selected: false

        },
        {
            name:"Stock",
            icon:"stock",
            route:"/Stock",
            selected: false

        },
        {
            name:"Vales",
            icon:"paybills",
            route:"/Paybills",
            selected: false

        },
        {
            name:"Facturacion",
            icon:"billing",
            route:"/Bills",
            selected: false

        }

    ];

    MenuListOther = [
        {
            name:"Dashboard",
            icon:"section",
            route:"/Dashboard",
            selected: true

        },
        {
            name:"Usuarios",
            icon:"user",
            route:"/Users",
            selected: false

        },
        {
            name:"Historial",
            icon:"historial",
            route:"/History",
            selected: false

        },
        {
            name:"Gastos",
            icon:"spends",
            route:"/Spends",
            selected: false

        },
        {
            name:"Ingresos",
            icon:"ingresses",
            route:"/Ingress",
            selected: false

        },
        {
            name:"Vales",
            icon:"paybills",
            route:"/Paybills",
            selected: false

        }

    ];

    function ReloadCarwashes(){

        $scope.LavadosMenu = [];

        //carga todos los lavados:
        if($scope.Profile.rol == "SuperAdministrador"){

            CarwashServ.All().then(function(data){

                console.log(data);

                angular.forEach(data.data.carwashes, function(carwash, key) {

                    var toAppend = {
                        id: carwash._id,
                        denomination: carwash.info.name
                    }

                    $scope.LavadosMenu.push(toAppend);
                });

                if($scope.LavadosMenu.length > 1){
                    $scope.LavadosMenu.push({id:0,denomination:'Todos'});
                }
                $scope.LavadoSelected($scope.LavadosMenu[0].id,$scope.LavadosMenu[0].denomination);
            });

        }else{

            //carga solo los lavados que le pertenecen
            CarwashServ.AllByAccount($scope.Profile.id).then(function(data){

                angular.forEach(data.data.carwashes, function(carwash, key) {

                    var toAppend = {
                        id: carwash._id,
                        denomination: carwash.info.name
                    }

                    $scope.LavadosMenu.push(toAppend);
                });

                if($scope.LavadosMenu.length > 1){
                    $scope.LavadosMenu.push({id:0,denomination:'Todos'});
                }
                $scope.LavadoSelected($scope.LavadosMenu[0].id,$scope.LavadosMenu[0].denomination);
            });
        }
    }

    Auth.GetUser().then(function(data) {
        console.log("GET USER");

        $scope.Profile = {
            name: data.data.user.info.name,
            id: data.data.user._id,
            rol: data.data.user.rol,
        };

        console.log($scope.Profile);


        CarwashVars.SetUser($scope.Profile);

        if($scope.Profile.rol == "SuperAdministrador"){
            $scope.Menu = MenuList;
        }else{
            $scope.Menu = MenuListOther;
        }

        ReloadCarwashes();
    });

    $scope.$on('ReloadCarwashes', function (event, data) {
        ReloadCarwashes();
    });

    $scope.ShowMenu = function() {
        $mdSidenav('left').toggle();
    }

    $scope.CloseMenu = function() {
        $mdSidenav('left').close();
    }

    $scope.LogOut = function(){
        Auth.LogOut();
        window.location = '/Home';
    }

    $scope.navigateTo = function(item){

        angular.forEach($scope.Menu, function(value, key) {
          value.selected = false;
        });

        if(item.name == "Lavados" || item.name == "Usuarios"|| item.name == "Autos"|| item.name == "Servicios" || item.name == "Insumos"){
            $scope.DisableMenu = true;
            $scope.TitleLavado = "";
        }else{
            $scope.DisableMenu = false;
            angular.forEach($scope.LavadosMenu, function(carwash, key) {
                if(carwash.id == $scope.AutoLavado){
                    $scope.TitleLavado = carwash.denomination;
                }
            });
            }

        item.selected = true;
        $scope.Tittle = item.name;
    	$location.path(item.route);
        $scope.CloseMenu();

    }

    $scope.LavadoSelected = function(Id,name){
        //para el menu:
        $scope.AutoLavado = Id;
        $scope.TitleLavado = name;
        //emite para los hijos y que se refresquen
        $scope.$broadcast('ChangeCarwash', Id);
        //el servicio por si cambian de pantalla /GET()
        CarwashVars.SetCarwash(Id);
    }

});
