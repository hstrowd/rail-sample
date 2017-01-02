class Header extends React.Component{

  renderNav() {
    var currentUser = $.auth.user;
    if (currentUser == null || currentUser.id == null) {
      return this.renderNavForNoUser();
    } else {
      return this.renderNavForActiveUser();
    }
  }

  renderNavForActiveUser() {
    var restrictedSiteAccess = [];
    if (($.auth.user.role == 'user_manager') || ($.auth.user.role == 'admin')) {
      restrictedSiteAccess.push(
        <li key='manage-users-nav'>
            <Link to='/users'>Manage Users</Link>
        </li>
      );
    }
    return (
      <span>
        <ul className="nav site-nav navbar-nav">
          <li key='dashboard-nav'>
              <Link to='/dashboard'>Dashboard</Link>
          </li>
          {restrictedSiteAccess}
        </ul>
        <ul className="nav user-nav navbar-nav pull-right">
          <li key='profile-nav'>
              <Link to='/profile'>Profile</Link>
          </li>
          <li key='logout-nav'>
              <Link to='/logout'>Logout</Link>
          </li>
        </ul>
      </span>
    );
  }

  renderNavForNoUser() {
    return (
      <span>
        <ul className="nav site-nav navbar-nav">
        </ul>
        <ul className="nav user-nav navbar-nav pull-right">
          <li key="login-nav">
              <Link to='/login'>Login</Link>
          </li>
          <li key="sign-up-nav">
              <Link to='/sign_up'>Sign Up</Link>
          </li>
        </ul>
      </span>
    );
  }

  render() {
    return (
      <nav className="navbar navbar-inverse navbar-fixed-top" role="navigation">
        <div className="container">
          <div className="navbar-header">
              <button className="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
                  <span className="sr-only">Toggle navigation</span>
                  <span className="icon-bar"></span>
                  <span className="icon-bar"></span>
                  <span className="icon-bar"></span>
              </button>
              <Link to='/' className="navbar-brand"><strong>Calorie Tracker</strong></Link>
          </div>
          <div className="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
              { this.renderNav() }
          </div>
        </div>
      </nav>
    );
  }

};
