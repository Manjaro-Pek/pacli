# Maintainer: Chrysostomus @forum.manjaro.org

pkgname=pacli
pkgver=0.8
pkgrel=1
pkgdesc="An interactive pacman interface using fzf"
arch=(any)
url="https://github.com/Manjaro-Pek/$pkgname"
license=(GPL2)
depends=('fzf'
	'pacman'
	'yaourt'
	'sudo'
	'gzip'
	'downgrade'
	'bash')
makedepends=('git')
optdepends=('update-notifier: Automatically get notified when updates are available'
    'pacman-mirrors: provides all mirrors for Manjaro'
    'reflector: retrieve and filter the latest Pacman mirror list')
source=("git://github.com/Manjaro-Pek/$pkgname")
md5sums=('SKIP')

package () {
    cd "$srcdir/$pkgname"
    install -dm755 "${pkgdir}/usr/lib/$pkgname"
    install -dm755 "${pkgdir}/usr/share/doc/$pkgname"

    install -Dm755 "$srcdir/$pkgname/pacli" "$pkgdir/usr/bin/pacli"
    cp -r lib/* "$pkgdir/usr/lib/$pkgname"
    chmod +x "$pkgdir/usr/lib/$pkgname/pacli-description.sh"
    # ln -s "$pkgdir/usr/lib/$pkgname/pacli-description.sh" "$pkgdir/etc/pacman.d/hooks/pacli-description.sh"

    install -Dm644 pacli.help "$pkgdir/usr/share/doc/$pkgname/help"
    for lg in {fr,fr}; do   #for lg in {fr,de,it,sp}; do
        install -Dm644 "pacli.$lg.help" "$pkgdir/usr/share/doc/$pkgname/$lg.help"
    done
}
