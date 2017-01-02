class Welcome extends React.Component {
  renderForActiveUser() {
    return (
      <div>
        <p>
          Head over to your <Link to='/dashboard'>dashboard</Link> to check out your progress and record your recent meals.
        </p>
      </div>
    );
  }

  renderForNoUser() {
    return (
      <div>
        <p>
          <Link to='/sign_up'>Sign up</Link> now to start tracking your daily calorie intake and making progress on your weight-loss goals.
        </p>
        <p>
          Already have an account? <Link to='/login'>Login</Link> and record your meals for the day in a few easy clicks.
        </p>
      </div>
    );
  }

  render() {
    var welcomeMsg = '';
    if ($.auth.user.id) {
      welcomeMsg = this.renderForActiveUser();
    } else {
      welcomeMsg = this.renderForNoUser();
    }
    return (
      <div>
        <div className="text-center"><h2>Welcome to the World's Best Calorie Tracker</h2></div>
        { welcomeMsg }
      </div>
    );
  }
};