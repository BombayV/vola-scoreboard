const doc = document;

window.addEventListener('load', () => {
    this.addEventListener('message', e => {
        if (e.data.action == 'openScoreboard') {
            doc.getElementById('wrapper').style.display = 'flex';
        }
        if (e.data.action == 'updatePlayers') {
            updateScoreboard(e.data.players, e.data.maxPlayers, e.data.runTime, e.data.jobs);
        }
    })

    doc.onkeyup = e => {
        const key = e.key
        if (key == 'Escape') {
            fetchNUI('close');
            doc.getElementById('wrapper').style.display = 'none';
        }
    }
})

const updateScoreboard = (players, maxPlayers, runTime, currJobs) => {
    const names = doc.getElementById('cont-names');
    const times = doc.getElementById('cont-time');
    const status = doc.getElementById('cont-status');

    for (let i=doc.getElementsByClassName('currentData').length - 1; i >= 0; i--) {
        doc.getElementsByClassName('currentData')[i].remove()
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
    doc.getElementById('curr-admin').textContent = currJobs.admin;
    doc.getElementById('curr-police').textContent = currJobs.police;
    doc.getElementById('curr-nhs').textContent = currJobs.nhs;
    doc.getElementById('curr-civilian').textContent = currJobs.civilian;
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