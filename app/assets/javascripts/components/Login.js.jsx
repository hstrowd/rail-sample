class Login extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      email: (this.props.email || ''),
      password: (this.props.password || '')
    };
  }

  updateEmail(event) {
    this.setState({ email: event.target.value });
  }
  updatePassword(event) {
    this.setState({ password: event.target.value });
  }

  handleSubmit(event) {
    event.preventDefault();
    Alerts.add('info', 'Logging in....').update();
    this.sendFormData();
  }

  sendFormData() {
    var credentials = {
      email: this.state.email,
      password: this.state.password
    };

    var self = this;
    $.auth.emailSignIn(credentials)
      .then(function(resp) {
        self.handleSuccess();
      })
      .fail(function(resp) {
        self.handleFailure();
      });
  }

  handleSuccess() {
    Alerts.add('success', 'Logged in.');
    window.location.assign('/#/dashboard');
  }
  handleFailure() {
    Alerts.add('danger', 'Login Failed.').update();
  }

  render() {
    if ($.auth.user.id) {
      Alerts.add('success', 'Already logged in.');
      window.location.assign('/#/dashboard');
      return null;
    }

    return (
      <div>
        <form onSubmit={this.handleSubmit.bind(this)}>
          <div className="form-group">
            <label>Email</label>
            <input type="text"
                   name="email"
                   className="form-control"
                   placeholder="john.doe@gmail.com"
                   required={true}
                   value={this.state.email}
                   onChange={this.updateEmail.bind(this)} />
          </div>
          <div className="form-group">
            <label>Password</label>
            <input type="password"
                   name="password"
                   className="form-control"
                   placeholder="Pa$$w0rd"
                   required={true}
                   value={this.state.password}
                   onChange={this.updatePassword.bind(this)} />
          </div>
          <div className="actions">
            <input type="submit"
                   className="btn btn-success"
                   value="Login" />
          </div>
        </form>
      </div>
    );
  }
};