class Logout extends React.Component {
  render() {
    Alerts.add('info', 'Logging out...').update();

    $.auth.signOut()
      .then(function(resp){
        Alerts.add('success', 'Logged out.');
        window.location.assign('/#/');
      })
      .fail(function(resp) {
        Alerts.add('danger', 'Logout Failed.').update();
      });

    return (
      <div></div>
    );
  }
};