// Javascript example
const Redis = require('ioredis');

const cluster = new Redis.Cluster([
  { port: 23647, password: '****', host: 'keydb-france-u525.vm.elestio.app' },
  {
    port: 23647,
    password: '****',
    host: 'keydb-netherlands-u525.vm.elestio.app',
  },
]);

cluster.set('foo', 'bar');
cluster.get('foo', (err, res) => {
  // res === 'bar'
});
