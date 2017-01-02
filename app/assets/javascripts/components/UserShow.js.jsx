class UserShow extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      userID: (this.props.params.userID || $.auth.user.id)
    };
  }

  componentWillReceiveProps(nextProps) {
    if (nextProps.params.userID != this.props.params.userID) {
      this.setState({ userID: (nextProps.params.userID || $.auth.user.id) });
    }
  }

  render() {
    if (!$.auth.user.id) {
      Alerts.add('warning', 'Login required.');
      window.location.assign('/#/');
      return null;
    }
    if ($.auth.user.role != ADMIN_ROLE && $.auth.user.id != this.state.userID) {
      Alerts.add('danger', 'Unauthorized Access.');
      window.location.assign('/#/');
      return null;
    }

    var title = '';
    if ($.auth.user.id == this.state.userID) {
      title = 'Welcome, ' + $.auth.user.name;
    } else {
      title = 'User Account Details';
    }
    return (
      <div>
        <div>
          <h2>{title}</h2>
        </div>
        <UserDetails userID={this.state.userID}
                     mealFilters={{}} />
      </div>
    );
  }
};