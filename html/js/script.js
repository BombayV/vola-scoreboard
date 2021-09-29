const doc = document;

window.addEventListener('load', () => {
    this.addEventListener('message', e => {
        if (e.data.action == 'updatePlayers') {
            updateScoreboard(e.data.players);
        }
    })

    doc.onkeyup = e => {
        const key = e.key
        if (key == 'Escape' || key == 'Home') {
            console.log('NUI: Scoreboard closed');
        }
    }
})

const updateScoreboard = data => {
    data.forEach(dataItem => {
        console.log(dataItem)
    });
}