// Javascript example
const Redis = require('ioredis');

const cluster = new Redis.Cluster([
  {
    port: 23647,
    password: '****',
    host: 'keydb-1-u525.vm.elestio.app',
  },
  {
    port: 23647,
    password: '****',
    host: 'keydb-2-u525.vm.elestio.app',
  },
]);

cluster.set('foo', 'bar');
cluster.get('foo', (err, res) => {
  // res === 'bar'
});
