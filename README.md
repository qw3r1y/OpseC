# OPSEC Araçları

Bu araç, güvenlik odaklı sistemlerinizi yapılandırmanıza, yönetmenize ve izlemeye yardımcı olmak için tasarlanmış 4 farklı bash betiğinden oluşmaktadır. Aşağıda araç hakkında detaylı bilgi ve kullanım talimatlarını bulabilirsiniz.

## Başlangıç

Aracı çalıştırmadan önce tüm dosyalara gerekli izinleri vermeniz gerekmektedir. Bunu şu şekilde yapabilirsiniz:

```bash
chmod +x *
./start.sh
```

`start.sh` dosyasını çalıştırdıktan sonra karşınıza 3 adet seçenek çıkacaktır:

### 1. Gerekli Dosyaların Yüklenmesi

Bu seçenek, OPSEC aracı için gerekli olan aşağıdaki araçları yükler:

- **Strongswan**: Güvenli VPN bağlantıları için kullanılan bir araç.
- **Tor**: İnternet gizliliği için anonimleştirici bir araç.
- **Suricata**: Ağ tabanlı tehdit algılama ve önleme aracı.
- **Chkrootkit**: Rootkit tespiti için kullanılan bir araç.
- **Rkhunter**: Rootkit tespiti ve sistem güvenliği denetimi sağlar.
- **ClamAV**: Virüs tarama ve zararlı yazılım analizi.
- **Firejail**: Uygulama izolasyonu sağlayan bir güvenlik aracı.
- **VPN Ayarları**: Güvenli bağlantı için VPN yapılandırma.
- **Tor Tarayıcı**: Anonim web taraması.
- **UFW (Uncomplicated Firewall)**: Basit ve etkili bir güvenlik duvarı aracı.
- **OpenSnitch**: Giden bağlantı izleme.
- **DNSCrypt**: DNS trafiğini şifrelemek için kullanılan bir araç.
- **ExifTool**: Dosya meta verilerini düzenler ve görüntüler.
- **BleachBit**: Disk temizleme ve gizlilik koruma aracı.
- **KeePass**: Parola yönetimi için bir yazılım.
- **Signal**: Güvenli mesajlaşma uygulaması.
- **Fail2Ban**: Brute force saldırılarına karşı koruma.
- **OSSEC**: Host tabanlı güvenlik ve log analizi aracı.



Bu bölümde üç alt seçenek bulunur:

1. **Temiz Kurulum:**
   - Sisteminizde daha önce yüklenmiş olan dosyalar varsa, bunları kaldırır ve sıfırdan temiz bir kurulum yapar.

2. **Eksik Araçların Yüklenmesi:**
   - Araçların sisteminizde mevcut olup olmadığını kontrol eder ve eksik olanları yükler.
   - Eksik olan aşağıdaki araçların tamamlanmasını sağlar:
     - **Strongswan, Tor, Suricata, Chkrootkit, Rkhunter, ClamAV, Firejail, VPN Ayarları, Tor Tarayıcı, UFW, OpenSnitch, DNSCrypt, ExifTool, BleachBit, KeePass, Signal, Fail2Ban, OSSEC.**

3. **Tüm Araçların Yüklenmesi:**
   - Sisteminizde bulunup bulunmadığına bakmaksızın tüm aşağıdaki araçları yeniden yükler:
     - **Strongswan, Tor, Suricata, Chkrootkit, Rkhunter, ClamAV, Firejail, VPN Ayarları, Tor Tarayıcı, UFW, OpenSnitch, DNSCrypt, ExifTool, BleachBit, KeePass, Signal, Fail2Ban, OSSEC.**

### 2. Config Ayarları Menüsü

Bu seçenek ile yukarıda yüklenen araçların konfigürasyon ayarlarına erişebilirsiniz. İsteğinize bağlı olarak belirli araçları özelleştirilebilir ya da tüm araçlar için varsayılan ayarları uygulayabilirsiniz.

- **Otomatik Ayarlar:**
  - 22, 21, 3389 gibi uzak erişim portları (SSH, FTP vb.) kapatılmıştır.
  - Sistem brute force saldırılarına karşı korunmuştur.
  - DNSCrypt aracı etkinleştirilmiştir.

- **Araç Ayarları:**
  - **Firejail**: Uygulama izolasyonu yapılandırılır ve kullanımı açıklanır.
  - **UFW**: Basit ve etkili bir güvenlik duvarı aracı için portlar yapılandırılır.
  - **OpenSnitch**: Giden bağlantı izleme aracı elle başlatma hatırlatması yapılır.
  - **DNSCrypt**: DNS trafiğinin şifrelenmesi etkinleştirilir.
  - **Fail2Ban**: Brute force saldırılarına karşı koruma kuralları yapılandırılır.
  - **Suricata**: Ağ tabanlı tehdit algılama ve önleme aracı yapılandırılır.
  - **Güvenlik Taramaları**: Sistem güvenliği için taramalar yapılır.
  - **Tor**: Gizlilik ve anonimlik için Tor yapılandırılır.


### 3. Logları ve Aktif Kuralları Görüntüleme

Bu seçenek ile sistemde yüklü olan araçlardan gelen logları ve aktif güvenlik kurallarını görebilirsiniz.

- **Suricata ve OSSEC Logları:**
  - Sistem üzerindeki şüpheli aktiviteleri tespit edebilirsiniz.

- **Kapalı Portlar ve Kurallar:**
  - Yetkisiz erişime kapalı olan portlar ve aktif güvenlik kurallarını görüntüleyebilirsiniz.

- **Dnscrypt Etkinleştirme:**
  - Dnsycriptin etkin olup olmadığını görmeninizi sağlar.

 
## Kullanım Notları

- Araç, Linux tabanlı sistemlerde çalışmak üzere tasarlanmıştır.
- `start.sh` dosyasını çalıştırmadan önce gerekli izinlerin verildiğinden emin olun.
- Yüklenilen araçlar ve konfigürasyonlar hakkında daha fazla bilgi almak için ilgili araçların dokümantasyona göz atabilirsiniz.
