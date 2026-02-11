// ========================================
// ABYSS VM - DISCORD BOT
// ========================================
// Ofuscá y ejecutá código desde Discord.
// ========================================

const { Client, GatewayIntentBits, AttachmentBuilder, EmbedBuilder } = require('discord.js');
const { exec, spawn } = require('child_process');
const fs = require('fs').promises;
const path = require('path');
const crypto = require('crypto');
const config = require('./config.json');

class AbyssBot {
    constructor() {
        this.client = new Client({
            intents: [
                GatewayIntentBits.Guilds,
                GatewayIntentBits.GuildMessages,
                GatewayIntentBits.MessageContent
            ]
        });
        
        this.stats = {
            totalExecutions: 0,
            totalObfuscations: 0,
            uptime: Date.now()
        };
        
        this.setupHandlers();
    }
    
    setupHandlers() {
        this.client.on('ready', () => {
            console.log(`✅ ABYSS VM - Conectado como ${this.client.user.tag}`);
            console.log(`🔥 Modo: ${config.mode} | Anti-tamper: ${config.antitamper ? 'ON' : 'OFF'}`);
            this.client.user.setActivity('!vm-help | Abyss VM', { type: 'WATCHING' });
        });
        
        this.client.on('messageCreate', async (message) => {
            if (message.author.bot) return;
            
            // Comando: !vm
            if (message.content.startsWith('!vm')) {
                await this.handleVM(message);
            }
            
            // Comando: !vm-protect
            if (message.content.startsWith('!vm-protect')) {
                await this.handleProtect(message);
            }
            
            // Comando: !vm-bytecode
            if (message.content.startsWith('!vm-bytecode')) {
                await this.handleBytecode(message);
            }
            
            // Comando: !vm-stats
            if (message.content === '!vm-stats') {
                await this.showStats(message);
            }
            
            // Comando: !vm-help
            if (message.content === '!vm-help') {
                await this.showHelp(message);
            }
        });
    }
    
    async handleVM(message) {
        const code = message.content.replace('!vm', '').trim();
        if (!code) {
            return message.reply('❌ Tenés que poner código Luau, hermano.');
        }
        
        const status = await message.reply('⚡ Inicializando Abyss VM...');
        
        try {
            const jobId = crypto.randomBytes(4).toString('hex');
            const tempFile = `/tmp/abyss_${jobId}.lua`;
            
            await fs.writeFile(tempFile, code);
            
            const vmProcess = spawn('lua', ['vm/core.lua', tempFile], {
                timeout: 30000,
                killSignal: 'SIGTERM'
            });
            
            let output = '';
            let error = '';
            
            vmProcess.stdout.on('data', (data) => output += data.toString());
            vmProcess.stderr.on('data', (data) => error += data.toString());
            
            vmProcess.on('close', async (code) => {
                await fs.unlink(tempFile).catch(() => {});
                
                if (code !== 0) {
                    return await status.edit(`❌ Error VM: ${error || 'Error desconocido'}`);
                }
                
                const embed = new EmbedBuilder()
                    .setColor(0x00FF00)
                    .setTitle('✅ ABYSS VM - EJECUCIÓN COMPLETADA')
                    .addFields(
                        { name: 'Job ID', value: jobId, inline: true },
                        { name: 'Output', value: output.substring(0, 100) + (output.length > 100 ? '...' : ''), inline: false }
                    )
                    .setTimestamp();
                
                await status.edit({ embeds: [embed] });
                this.stats.totalExecutions++;
            });
            
        } catch (e) {
            await status.edit(`❌ Error: ${e.message}`);
        }
    }
    
    async handleProtect(message) {
        const code = message.content.replace('!vm-protect', '').trim();
        if (!code) {
            return message.reply('❌ Tenés que poner código para ofuscar.');
        }
        
        const status = await message.reply('🔒 Ofuscando con Abyss VM...');
        
        try {
            const jobId = crypto.randomBytes(4).toString('hex');
            const tempFile = `/tmp/abyss_${jobId}.lua`;
            
            await fs.writeFile(tempFile, code);
            
            // Ejecutar ofuscador
            const obfProcess = spawn('lua', ['obfuscator/engine.lua', tempFile], {
                timeout: 10000
            });
            
            let obfuscated = '';
            let obfError = '';
            
            obfProcess.stdout.on('data', (data) => obfuscated += data.toString());
            obfProcess.stderr.on('data', (data) => obfError += data.toString());
            
            obfProcess.on('close', async (code) => {
                await fs.unlink(tempFile).catch(() => {});
                
                if (code !== 0 || !obfuscated) {
                    return await status.edit(`❌ Error ofuscador: ${obfError || 'Error desconocido'}`);
                }
                
                const buffer = Buffer.from(obfuscated);
                const attachment = new AttachmentBuilder(buffer, {
                    name: `abyss_${jobId}.lua`
                });
                
                const embed = new EmbedBuilder()
                    .setColor(0x9B59B6)
                    .setTitle('🔒 ABYSS VM - OFUSCACIÓN COMPLETADA')
                    .addFields(
                        { name: 'Job ID', value: jobId, inline: true },
                        { name: 'Tamaño', value: `${buffer.length} bytes`, inline: true },
                        { name: 'Anti-tamper', value: config.antitamper ? '✅ ACTIVADO' : '❌ DESACTIVADO', inline: true }
                    )
                    .setTimestamp();
                
                await status.edit({ embeds: [embed], files: [attachment] });
                this.stats.totalObfuscations++;
            });
            
        } catch (e) {
            await status.edit(`❌ Error: ${e.message}`);
        }
    }
    
    async showHelp(message) {
        const embed = new EmbedBuilder()
            .setColor(0x9B59B6)
            .setTitle('🔥 ABYSS VM - MANUAL OFICIAL')
            .setDescription('**La máquina virtual que rompe decompiladores**')
            .addFields(
                { name: '📌 COMANDOS', value: `
\`!vm <código>\` - Ejecutar código en Abyss VM
\`!vm-protect <código>\` - Ofuscar código con Abyss
\`!vm-bytecode <código>\` - Ver bytecode generado
\`!vm-stats\` - Estadísticas del bot
\`!vm-help\` - Esta ayuda
                ` },
                { name: '🛡️ PROTECCIONES', value: `
✅ VM propia (bytecode personalizado)
✅ Anti-tamper (7 capas)
✅ Control Flow Flattening
✅ Polimorfismo dinámico
✅ 100% local, 0 dependencias
                ` }
            )
            .setFooter({ text: 'Abyss VM - Solo para los que entienden' })
            .setTimestamp();
        
        await message.reply({ embeds: [embed] });
    }
    
    async showStats(message) {
        const uptime = Math.floor((Date.now() - this.stats.uptime) / 1000);
        const hours = Math.floor(uptime / 3600);
        const minutes = Math.floor((uptime % 3600) / 60);
        
        const embed = new EmbedBuilder()
            .setColor(0x3498DB)
            .setTitle('📊 ABYSS VM - ESTADÍSTICAS')
            .addFields(
                { name: '⏱️ Uptime', value: `${hours}h ${minutes}m`, inline: true },
                { name: '📁 Ejecuciones', value: `${this.stats.totalExecutions}`, inline: true },
                { name: '🔐 Ofuscaciones', value: `${this.stats.totalObfuscations}`, inline: true }
            )
            .setTimestamp();
        
        await message.reply({ embeds: [embed] });
    }
    
    start() {
        this.client.login(config.token);
    }
}

// Iniciar bot
const bot = new AbyssBot();
bot.start();
