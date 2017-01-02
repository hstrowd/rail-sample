var Route = ReactRouter.Route,
    DefaultRoute = ReactRouter.DefaultRoute;

var AppRoutes = (
  <Route handler={App}>
    <DefaultRoute handler={Welcome} />

    <Route handler={Login}   path='login' />
    <Route handler={Logout}  path='logout' />
    <Route handler={UserNew} path='sign_up' />

    <Route handler={UsersIndex} path='users' />
    <Route handler={UserNew}    path='users/new' />
    <Route handler={UserShow}   path='dashboard' />
    <Route handler={UserEdit}   path='profile' />
    <Route handler={UserShow}   path='users/:userID' />
    <Route handler={UserEdit}   path='users/:userID/edit' />

    <Route handler={MealNew}  path='users/:userID/meals/new' />
    <Route handler={MealEdit} path='users/:userID/meals/:mealID/edit' />
  </Route>
);