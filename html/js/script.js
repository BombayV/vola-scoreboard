const doc = document;

window.addEventListener('load', () => {
    this.addEventListener('message', e => {
        if (e.data.action == 'openScoreboard') {
            doc.getElementById('wrapper').style.display = 'flex';
        }
        if (e.data.action == 'updatePlayers') {
            updateScoreboard(e.data.players, e.data.maxPlayers, e.data.runTime);
        }
    })

    doc.onkeyup = e => {
        const key = e.key
        if (key == 'Escape') {
            console.log('NUI: Scoreboard closed');
            fetchNUI('close')
            doc.getElementById('wrapper').style.display = 'none';
        }
    }
})

/**
 * @param {Object[]} players - Array of players
*/

const updateScoreboard = (players, maxPlayers, runTime) => {
    const names = doc.getElementById('cont-names');
    const times = doc.getElementById('cont-time');
    const status = doc.getElementById('cont-status');

    for (let i=doc.getElementsByClassName('currentData').length - 1; i >= 0; i--) {
        if (doc.getElementsByClassName('currentData')[i].className.split(' ')[1] != players.indexOf(players[doc.getElementsByClassName('currentData')[i].className.split(' ')[1]])) {
            doc.getElementsByClassName('currentData')[i].remove()
        }
    }

    players.forEach(player => {
        if (!doc.getElementById(player.playersName)) {
            const name = doc.createElement('span');
            const time = doc.createElement('span');
            const job = doc.createElement('span');

            time.textContent = player.playersTime;
            name.textContent = player.playersName;
            job.textContent = player.playersJob;

            name.id = player.playersName;
            time.classList.add('currentData', players.indexOf(player));
            name.classList.add('currentData',players.indexOf(player));
            job.classList.add('currentData', players.indexOf(player));

            names.appendChild(name);
            times.appendChild(time);
            status.appendChild(job);
        }
    });

    doc.getElementById('players').textContent = maxPlayers;
    doc.getElementById('runtime').textContent = runTime;
}

const fetchNUI = async (cbname, data) => {
    const options = {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data)
    };
    const resp = await fetch(`https://vola-scoreboard/${cbname}`, options);
    return await resp.json();
}